(*
   Copyright 2008-2015 Abhishek Anand, Nikhil Swamy and Microsoft Research

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*)
(* -------------------------------------------------------------------- *)
#light "off"

module FStar.Extraction.Kremlin

open FStar
open FStar.Util
open FStar.Extraction.ML
open FStar.Extraction.ML.Syntax
open FStar.Format
open FStar.Const
open FStar.BaseTypes

(* COPY-PASTED ****************************************************************)

type program =
  list<decl>

and decl =
  | DFunction of typ * ident * list<binder> * expr
  | DTypeAlias of ident * typ
  | DGlobal of ident * typ * expr

and expr =
  | EBound of var
  | EOpen of binder
  | EQualified of lident
  | EConstant of constant
  | EUnit
  | EApp of expr * list<expr>
  | ELet of binder * expr * expr
  | EIfThenElse of expr * expr * expr
  | ESequence of list<expr>
  | EAssign of expr * expr
    (** left expression can only be a EBound of EOpen *)
  | EBufCreate of expr * expr
  | EBufRead of expr * expr
  | EBufWrite of expr * expr * expr
  | EBufSub of expr * expr
  | EBufBlit of expr * expr * expr * expr * expr
  | EMatch of expr * branches
  | EOp of op * width
  | ECast of expr * typ
  | EPushFrame
  | EPopFrame
  | EBool of bool

and op =
  | Add | AddW | Sub | SubW | Div | Mult | Mod
  | BOr | BAnd | BXor | BShiftL | BShiftR
  | Eq | Lt | Lte | Gt | Gte

and branches =
  list<branch>

and branch =
  pattern * expr

and pattern =
  | PUnit
  | PBool of bool
  | PVar of binder

and width =
  | UInt8
  | UInt16
  | UInt32
  | UInt64
  | Int8
  | Int16
  | Int32
  | Int64

and constant = width * string

and var =
  int (** a De Bruijn index *)

and binder = {
  name: ident;
  typ: typ;
  mut: bool;
  mark: int;
}

and ident =
  string (** for pretty-printing *)

and lident =
  list<ident> * ident

and typ =
  | TInt of width
  | TBuf of typ
  | TUnit
  | TQualified of lident
  | TBool
  | TAny
  | TArrow of typ * typ
  | TZ

(** Versioned binary writing/reading of ASTs *)

type version = int
let current_version: version = 5

type file = string * program
type binary_format = version * list<file>


(* Utilities *****************************************************************)

let fst3 (x, _, _) = x
let snd3 (_, x, _) = x
let thd3 (_, _, x) = x

let mk_width = function
  | "UInt8" -> Some UInt8
  | "UInt16" -> Some UInt16
  | "UInt32" -> Some UInt32
  | "UInt64" -> Some UInt64
  | "Int8" -> Some Int8
  | "Int16" -> Some Int16
  | "Int32" -> Some Int32
  | "Int64" -> Some Int64
  | _ -> None

let mk_op = function
  | "add" | "op_Plus_Hat" ->
      Some Add
  | "add_mod" | "op_Plus_Percent_Hat" ->
      Some AddW
  | "sub" | "op_Subtraction_Hat" ->
      Some Sub
  | "sub_mod" | "op_Subtraction_Percent_Hat" ->
      Some SubW
  | "mul" | "op_Star_Hat" ->
      Some Mult
  | "div" | "op_Slash_Hat" ->
      Some Div
  | "rem" | "op_Percent_Hat" ->
      Some Mod
  | "logor" | "op_Bar_Hat" ->
      Some BOr
  | "logxor" | "op_Hat_Hat" ->
      Some BXor
  | "logand" | "op_Amp_Hat" ->
      Some BAnd
  | "shift_right" | "op_Greater_Greater_Hat" ->
      Some BShiftR
  | "shift_left" | "op_Less_Less_Hat" ->
      Some BShiftL
  | "eq" | "op_Equals_Hat" ->
      Some Eq
  | "op_Greater_Hat" | "gt" ->
      Some Gt
  | "op_Greater_Equal_Hat" | "gte" ->
      Some Gte
  | "op_Less_Hat" | "lt" ->
      Some Lt
  | "op_Less_Equal_Hat" | "lte" ->
      Some Lte
  | _ ->
      None

let is_op op =
  mk_op op <> None

let is_machine_int m =
  mk_width m <> None

(* Environments **************************************************************)

type env = {
  names: list<name>;
  module_name: string;
}

and name = {
  pretty: string;
  mut: bool;
}

let empty module_name = {
  names = [];
  module_name = module_name
}

let extend env x is_mut =
  { env with names = { pretty = x; mut = is_mut } :: env.names }

let find_name env x =
  match List.tryFind (fun name -> name.pretty = x) env.names with
  | Some name ->
      name
  | None ->
      failwith "internal error: name not found"

let is_mutable env x =
  (find_name env x).mut

let find env x =
  try
    List.index (fun name -> name.pretty = x) env.names
  with _ ->
    failwith (Util.format1 "Internal error: name not found %s\n" x)

let add_binders env binders =
  List.fold_left (fun env ((name, _), _) -> extend env name false) env binders

(* Actual translation ********************************************************)

let rec translate (MLLib modules): list<file> =
  List.filter_map (fun m ->
    try
      Util.print1 "Attempting to translate module %s\n" (fst3 m);
      Some (translate_module m)
    with
    | e ->
        Util.print2 "Unable to translate module: %s because:\n  %s\n"
          (fst3 m) (Util.print_exn e);
        None
  ) modules

and translate_module (module_name, modul, _): file =
  let program = match modul with
    | Some (_signature, decls) ->
        List.filter_map (translate_decl (empty module_name)) decls
    | _ ->
        failwith "Unexpected standalone interface or nested modules"
  in
  module_name, program

and translate_decl env d: option<decl> =
  match d with
  | MLM_Let (flavor, [ {
      mllb_name = name, _;
      mllb_tysc = Some ([], MLTY_Fun (_, _, t));
      mllb_def = { expr = MLE_Fun (args, body) }
    } ]) ->
      assert (flavor <> Mutable);
      begin try
        let env = if flavor = Rec then extend env name false else env in
        let rec find_return_type = function
          | MLTY_Fun (_, _, t) ->
              find_return_type t
          | t ->
              t
        in
        let t = translate_type env (find_return_type t) in
        let binders = translate_binders env args in
        let env = add_binders env args in
        let body = translate_expr env body in
        let name = env.module_name ^ "_" ^ name in
        Some (DFunction (t, name, binders, body))
      with e ->
        Util.print2 "Warning: not translating definition for %s (%s)\n" name (Util.print_exn e);
        None
      end

  | MLM_Let (flavor, [ {
      mllb_name = name, _;
      mllb_tysc = Some ([], t);
      mllb_def = expr
    } ]) ->
      assert (flavor <> Mutable);
      begin try
        let t = translate_type env t in
        let expr = translate_expr env expr in
        let name = env.module_name ^ "_" ^ name in
        Some (DGlobal (name, t, expr))
      with e ->
        Util.print2 "Warning: not translating definition for %s (%s)\n" name (Util.print_exn e);
        None
      end

  | MLM_Let (_, { mllb_name = name, _ } :: _) ->
      (* Things we currently do not translate:
       * - polymorphic functions (lemmas do count, sadly)
       *)
      Util.print1 "Warning: not translating definition for %s (and possibly others)\n" name;
      None

  | MLM_Let _ ->
      failwith "impossible"

  | MLM_Loc _ ->
      None

  | MLM_Ty [ (name, [], Some (MLTD_Abbrev t)) ] ->
      let name = env.module_name ^ "_" ^ name in
      Some (DTypeAlias (name, translate_type env t))

  | MLM_Ty ((name, _, _) :: _) ->
      Util.print1 "Warning: not translating definition for %s (and possibly others)\n" name;
      None

  | MLM_Top _ ->
      failwith "todo: translate_decl [MLM_Top]"

  | MLM_Exn _ ->
      failwith "todo: translate_decl [MLM_Exn]"

and translate_type env t: typ =
  match t with
  | MLTY_Tuple []
  | MLTY_Top ->
      TUnit
  | MLTY_Var _ ->
      failwith "todo: translate_type [MLTY_Var]"
  | MLTY_Fun (t1, _, t2) ->
      TArrow (translate_type env t1, translate_type env t2)
  | MLTY_Named ([], p) when (Syntax.string_of_mlpath p = "Prims.unit") ->
      TUnit
  | MLTY_Named ([], p) when (Syntax.string_of_mlpath p = "Prims.bool") ->
      TBool
  | MLTY_Named ([], p) when (Syntax.string_of_mlpath p = "Prims.int") ->
      failwith "todo: translate_type [Prims.int]"
  | MLTY_Named ([], p) when (Syntax.string_of_mlpath p = "FStar.UInt8.t") ->
      TInt UInt8
  | MLTY_Named ([], p) when (Syntax.string_of_mlpath p = "FStar.UInt16.t") ->
      TInt UInt16
  | MLTY_Named ([], p) when (Syntax.string_of_mlpath p = "FStar.UInt32.t") ->
      TInt UInt32
  | MLTY_Named ([], p) when (Syntax.string_of_mlpath p = "FStar.UInt64.t") ->
      TInt UInt64
  | MLTY_Named ([], p) when (Syntax.string_of_mlpath p = "FStar.Int8.t") ->
      TInt Int8
  | MLTY_Named ([], p) when (Syntax.string_of_mlpath p = "FStar.Int16.t") ->
      TInt Int16
  | MLTY_Named ([], p) when (Syntax.string_of_mlpath p = "FStar.Int32.t") ->
      TInt Int32
  | MLTY_Named ([], p) when (Syntax.string_of_mlpath p = "FStar.Int64.t") ->
      TInt Int64
  | MLTY_Named ([arg], p) when (Syntax.string_of_mlpath p = "FStar.Buffer.buffer") ->
      TBuf (translate_type env arg)
  | MLTY_Named ([], p) when (Syntax.string_of_mlpath p = "FStar.HyperStack.mem") ->
      // HACK ALERT HACK ALERT we shouldn't even be extracting this!
      TAny
  | MLTY_Named ([_], p) when (Syntax.string_of_mlpath p = "FStar.Ghost.erased") ->
      TAny
  | MLTY_Named ([], (path, type_name)) ->
      TQualified (path, type_name)
  | MLTY_Named (_, p) ->
      failwith (Util.format2 "todo: translate_type [MLTY_Named] %s (module_name = %s)"
        (Syntax.string_of_mlpath p) env.module_name)
  | MLTY_Tuple _ ->
      failwith "todo: translate_type [MLTY_Tuple]"

and translate_binders env args =
  List.map (translate_binder env) args

and translate_binder env ((name, _), typ) =
  { name = name; typ = translate_type env typ; mut = false; mark = 0 }

and translate_expr env e: expr =
  match e.expr with
  | MLE_Tuple [] ->
      EUnit

  | MLE_Const c ->
      translate_constant c

  | MLE_Var (name, _) ->
      EBound (find env name)

  // Some of these may not appear beneath an [EApp] node because of partial applications
  | MLE_Name ([ "FStar"; m ], op) when (is_machine_int m && is_op op) ->
      EOp (must (mk_op op), must (mk_width m))

  | MLE_Name n ->
      EQualified n

  | MLE_Let ((flavor, [{
      mllb_name = name, _;
      mllb_tysc = Some ([], typ); // assuming unquantified type
      mllb_add_unit = add_unit; // ?
      mllb_def = body;
      print_typ = print // ?
    }]), continuation) ->
      let typ, body =
        if flavor = Mutable then
          (match typ with
          | MLTY_Named ([ t ], p) when (string_of_mlpath p = "FStar.HST.salloc") -> t
          | _ -> failwith "unexpected: bad desugaring of Mutable"),
          (match body with
          | { expr = MLE_App (_, [ body ]) } -> body
          | _ -> failwith "unexpected: bad desugaring of Mutable")
        else
          typ, body
      in
      let is_mut = flavor = Mutable in
      let binder = { name = name; typ = translate_type env typ; mut = is_mut; mark = 0 } in
      let body = translate_expr env body in
      let env = extend env name is_mut in
      let continuation = translate_expr env continuation in
      ELet (binder, body, continuation)

  | MLE_Match (expr, branches) ->
      let t = expr.mlty in
      EMatch (translate_expr env expr, translate_branches env t branches)

  // We recognize certain distinguished names from [FStar.HST] and other
  // modules, and translate them into built-in Kremlin constructs
  | MLE_App ({ expr = MLE_Name p }, [ { expr = MLE_Var (v, _) } ]) when (string_of_mlpath p = "FStar.HST.op_Bang" && is_mutable env v) ->
      EBound (find env v)
  | MLE_App ({ expr = MLE_Name p }, [ { expr = MLE_Var (v, _) }; e ]) when (string_of_mlpath p = "FStar.HST.op_Colon_Equals" && is_mutable env v) ->
      EAssign (EBound (find env v), translate_expr env e)
  | MLE_App ({ expr = MLE_Name p }, [ e1; e2 ]) when (string_of_mlpath p = "FStar.Buffer.index") ->
      EBufRead (translate_expr env e1, translate_expr env e2)
  | MLE_App ({ expr = MLE_Name p }, [ e1; e2 ]) when (string_of_mlpath p = "FStar.Buffer.create") ->
      EBufCreate (translate_expr env e1, translate_expr env e2)
  | MLE_App ({ expr = MLE_Name p }, [ e1; e2; _e3 ]) when (string_of_mlpath p = "FStar.Buffer.sub") ->
      EBufSub (translate_expr env e1, translate_expr env e2)
  | MLE_App ({ expr = MLE_Name p }, [ e1; e2 ]) when (string_of_mlpath p = "FStar.Buffer.offset") ->
      EBufSub (translate_expr env e1, translate_expr env e2)
  | MLE_App ({ expr = MLE_Name p }, [ e1; e2; e3 ]) when (string_of_mlpath p = "FStar.Buffer.upd") ->
      EBufWrite (translate_expr env e1, translate_expr env e2, translate_expr env e3)
  | MLE_App ({ expr = MLE_Name p }, [ _ ]) when (string_of_mlpath p = "FStar.HST.push_frame") ->
      EPushFrame
  | MLE_App ({ expr = MLE_Name p }, [ _ ]) when (string_of_mlpath p = "FStar.HST.pop_frame") ->
      EPopFrame
  | MLE_App ({ expr = MLE_Name p }, [ e1; e2; e3; e4; e5 ]) when (string_of_mlpath p = "FStar.Buffer.blit") ->
      EBufBlit (translate_expr env e1, translate_expr env e2, translate_expr env e3, translate_expr env e4, translate_expr env e5)
  | MLE_App ({ expr = MLE_Name p }, [ _ ]) when (string_of_mlpath p = "FStar.HST.get") ->
      // HACK ALERT HACK ALERT we shouldn't even be extracting this!
      EConstant (UInt8, "0")

  // Operators from fixed-width integer modules, e.g. [FStar.Int32.addw].
  | MLE_App ({ expr = MLE_Name ([ "FStar"; m ], op) }, args) when (is_machine_int m && is_op op) ->
      mk_op_app env (must (mk_width m)) (must (mk_op op)) args

  // Fixed-width literals are represented as calls to [FStar.Int32.uint_to_t]
  | MLE_App ({ expr = MLE_Name ([ "FStar"; m ], "uint_to_t") }, [ { expr = MLE_Const (MLC_Int (c, None)) }]) when is_machine_int m ->
      EConstant (must (mk_width m), c)

  | MLE_App ({ expr = MLE_Name ([ "FStar"; "Int"; "Cast" ], c) }, [ arg ]) ->
      if ends_with c "uint64" then
        ECast (translate_expr env arg, TInt UInt64)
      else if ends_with c "uint32" then
        ECast (translate_expr env arg, TInt UInt32)
      else if ends_with c "uint16" then
        ECast (translate_expr env arg, TInt UInt16)
      else if ends_with c "uint8" then
        ECast (translate_expr env arg, TInt UInt8)
      else if ends_with c "int64" then
        ECast (translate_expr env arg, TInt Int64)
      else if ends_with c "int32" then
        ECast (translate_expr env arg, TInt Int32)
      else if ends_with c "int16" then
        ECast (translate_expr env arg, TInt Int16)
      else if ends_with c "int8" then
        ECast (translate_expr env arg, TInt Int8)
      else
        failwith (Util.format1 "Unrecognized function from Cast module: %s\n" c)

  | MLE_App ({ expr = MLE_Name (path, function_name) }, args) ->
      EApp (EQualified (path, function_name), List.map (translate_expr env) args)

  | MLE_Coerce ({ expr = MLE_Const MLC_Unit }, t_from, t_to) ->
      ECast (EUnit, translate_type env t_to)

  | MLE_Let _ ->
      (* Things not supported (yet): let-bindings for functions; meaning, rec flags are not
       * supported, and quantified type schemes are not supported either *)
      failwith "todo: translate_expr [MLE_Let]"
  | MLE_App _ ->
      failwith "todo: translate_expr [MLE_App]"
  | MLE_Fun _ ->
      failwith "todo: translate_expr [MLE_Fun]"
  | MLE_CTor _ ->
      failwith "todo: translate_expr [MLE_CTor]"
  | MLE_Seq seqs ->
      ESequence (List.map (translate_expr env) seqs)
  | MLE_Tuple _ ->
      failwith "todo: translate_expr [MLE_Tuple]"
  | MLE_Record _ ->
      failwith "todo: translate_expr [MLE_Record]"
  | MLE_Proj _ ->
      failwith "todo: translate_expr [MLE_Proj]"
  | MLE_If _ ->
      failwith "todo: translate_expr [MLE_If]"
  | MLE_Raise _ ->
      failwith "todo: translate_expr [MLE_Raise]"
  | MLE_Try _ ->
      failwith "todo: translate_expr [MLE_Try]"

and translate_branches env t branches =
  List.map (translate_branch env t) branches

and translate_branch env t (pat, guard, expr) =
  if guard = None then
    let env, pat = translate_pat env t pat in
    pat, translate_expr env expr
  else
    failwith "todo: translate_branch"

and translate_pat env t p =
  match p with
  | MLP_Const MLC_Unit ->
      env, PUnit
  | MLP_Const (MLC_Bool b) ->
      env, PBool b
  | MLP_Var (name, _) ->
      let env = extend env name false in
      env, PVar ({ name = name; typ = translate_type env t; mut = false; mark = 0 })
  | MLP_Wild ->
      failwith "todo: translate_pat [MLP_Wild]"
  | MLP_Const _ ->
      failwith "todo: translate_pat [MLP_Const]"
  | MLP_CTor _ ->
      failwith "todo: translate_pat [MLP_CTor]"
  | MLP_Branch _ ->
      failwith "todo: translate_pat [MLP_Branch]"
  | MLP_Record _ ->
      failwith "todo: translate_pat [MLP_Record]"
  | MLP_Tuple _ ->
      failwith "todo: translate_pat [MLP_Tuple]"

and translate_constant c: expr =
  match c with
  | MLC_Unit ->
      EUnit
  | MLC_Bool b ->
      EBool b
  | MLC_Int (s, Some _) ->
      failwith "impossible: machine integer not desugared to a function call"
  | MLC_Float _ ->
      failwith "todo: translate_expr [MLC_Float]"
  | MLC_Char _ ->
      failwith "todo: translate_expr [MLC_Char]"
  | MLC_String _ ->
      failwith "todo: translate_expr [MLC_String]"
  | MLC_Bytes _ ->
      failwith "todo: translate_expr [MLC_Bytes]"

(* Helper functions **********************************************************)

and mk_op_app env w op args =
  EApp (EOp (op, w), List.map (translate_expr env) args)
