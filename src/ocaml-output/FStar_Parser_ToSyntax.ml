
open Prims

let trans_aqual : FStar_Parser_AST.arg_qualifier Prims.option  ->  FStar_Syntax_Syntax.arg_qualifier Prims.option = (fun _63_1 -> (match (_63_1) with
| Some (FStar_Parser_AST.Implicit) -> begin
Some (FStar_Syntax_Syntax.imp_tag)
end
| Some (FStar_Parser_AST.Equality) -> begin
Some (FStar_Syntax_Syntax.Equality)
end
| _63_28 -> begin
None
end))


let trans_qual : FStar_Range.range  ->  FStar_Parser_AST.qualifier  ->  FStar_Syntax_Syntax.qualifier = (fun r _63_2 -> (match (_63_2) with
| FStar_Parser_AST.Private -> begin
FStar_Syntax_Syntax.Private
end
| FStar_Parser_AST.Assumption -> begin
FStar_Syntax_Syntax.Assumption
end
| FStar_Parser_AST.Inline -> begin
FStar_Syntax_Syntax.Inline
end
| FStar_Parser_AST.Unfoldable -> begin
FStar_Syntax_Syntax.Unfoldable
end
| FStar_Parser_AST.Irreducible -> begin
FStar_Syntax_Syntax.Irreducible
end
| FStar_Parser_AST.Logic -> begin
FStar_Syntax_Syntax.Logic
end
| FStar_Parser_AST.TotalEffect -> begin
FStar_Syntax_Syntax.TotalEffect
end
| FStar_Parser_AST.Effect -> begin
FStar_Syntax_Syntax.Effect
end
| FStar_Parser_AST.New -> begin
FStar_Syntax_Syntax.New
end
| FStar_Parser_AST.Abstract -> begin
FStar_Syntax_Syntax.Abstract
end
| FStar_Parser_AST.Opaque -> begin
(

let _63_42 = (FStar_TypeChecker_Errors.warn r "The \'opaque\' qualifier is deprecated since its use was strangely schizophrenic. There were two overloaded uses: (1) Given \'opaque val f : t\', the behavior was to exclude the definition of \'f\' to the SMT solver. This corresponds roughly to the new \'irreducible\' qualifier. (2) Given \'opaque type t = t\'\', the behavior was to provide the definition of \'t\' to the SMT solver, but not to inline it, unless absolutely required for unification. This corresponds roughly to the behavior of \'unfoldable\' (which is currently the default).")
in FStar_Syntax_Syntax.Unfoldable)
end
| FStar_Parser_AST.Noeq -> begin
FStar_Syntax_Syntax.Noeq
end
| FStar_Parser_AST.DefaultEffect -> begin
(Prims.raise (FStar_Syntax_Syntax.Error (("The \'default\' qualifier on effects is no longer supported", r))))
end))


let trans_pragma : FStar_Parser_AST.pragma  ->  FStar_Syntax_Syntax.pragma = (fun _63_3 -> (match (_63_3) with
| FStar_Parser_AST.SetOptions (s) -> begin
FStar_Syntax_Syntax.SetOptions (s)
end
| FStar_Parser_AST.ResetOptions (sopt) -> begin
FStar_Syntax_Syntax.ResetOptions (sopt)
end))


let as_imp : FStar_Parser_AST.imp  ->  FStar_Syntax_Syntax.arg_qualifier Prims.option = (fun _63_4 -> (match (_63_4) with
| FStar_Parser_AST.Hash -> begin
Some (FStar_Syntax_Syntax.imp_tag)
end
| _63_54 -> begin
None
end))


let arg_withimp_e = (fun imp t -> (t, (as_imp imp)))


let arg_withimp_t = (fun imp t -> (match (imp) with
| FStar_Parser_AST.Hash -> begin
(t, Some (FStar_Syntax_Syntax.imp_tag))
end
| _63_61 -> begin
(t, None)
end))


let contains_binder : FStar_Parser_AST.binder Prims.list  ->  Prims.bool = (fun binders -> (FStar_All.pipe_right binders (FStar_Util.for_some (fun b -> (match (b.FStar_Parser_AST.b) with
| FStar_Parser_AST.Annotated (_63_65) -> begin
true
end
| _63_68 -> begin
false
end)))))


let rec unparen : FStar_Parser_AST.term  ->  FStar_Parser_AST.term = (fun t -> (match (t.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Paren (t) -> begin
(unparen t)
end
| _63_73 -> begin
t
end))


let tm_type_z : FStar_Range.range  ->  FStar_Parser_AST.term = (fun r -> (let _154_23 = (let _154_22 = (FStar_Ident.lid_of_path (("Type0")::[]) r)
in FStar_Parser_AST.Name (_154_22))
in (FStar_Parser_AST.mk_term _154_23 r FStar_Parser_AST.Kind)))


let tm_type : FStar_Range.range  ->  FStar_Parser_AST.term = (fun r -> (let _154_27 = (let _154_26 = (FStar_Ident.lid_of_path (("Type")::[]) r)
in FStar_Parser_AST.Name (_154_26))
in (FStar_Parser_AST.mk_term _154_27 r FStar_Parser_AST.Kind)))


let rec delta_qualifier : FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.delta_depth = (fun t -> (

let t = (FStar_Syntax_Subst.compress t)
in (match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_delayed (_63_79) -> begin
(FStar_All.failwith "Impossible")
end
| FStar_Syntax_Syntax.Tm_fvar (fv) -> begin
fv.FStar_Syntax_Syntax.fv_delta
end
| (FStar_Syntax_Syntax.Tm_bvar (_)) | (FStar_Syntax_Syntax.Tm_name (_)) | (FStar_Syntax_Syntax.Tm_match (_)) | (FStar_Syntax_Syntax.Tm_uvar (_)) | (FStar_Syntax_Syntax.Tm_unknown) -> begin
FStar_Syntax_Syntax.Delta_equational
end
| (FStar_Syntax_Syntax.Tm_type (_)) | (FStar_Syntax_Syntax.Tm_constant (_)) | (FStar_Syntax_Syntax.Tm_arrow (_)) -> begin
FStar_Syntax_Syntax.Delta_constant
end
| (FStar_Syntax_Syntax.Tm_uinst (t, _)) | (FStar_Syntax_Syntax.Tm_refine ({FStar_Syntax_Syntax.ppname = _; FStar_Syntax_Syntax.index = _; FStar_Syntax_Syntax.sort = t}, _)) | (FStar_Syntax_Syntax.Tm_meta (t, _)) | (FStar_Syntax_Syntax.Tm_ascribed (t, _, _)) | (FStar_Syntax_Syntax.Tm_app (t, _)) | (FStar_Syntax_Syntax.Tm_abs (_, t, _)) | (FStar_Syntax_Syntax.Tm_let (_, t)) -> begin
(delta_qualifier t)
end)))


let incr_delta_qualifier : FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.delta_depth = (fun t -> (

let d = (delta_qualifier t)
in (

let rec aux = (fun d -> (match (d) with
| FStar_Syntax_Syntax.Delta_equational -> begin
d
end
| FStar_Syntax_Syntax.Delta_constant -> begin
FStar_Syntax_Syntax.Delta_unfoldable (1)
end
| FStar_Syntax_Syntax.Delta_unfoldable (i) -> begin
FStar_Syntax_Syntax.Delta_unfoldable ((i + 1))
end
| FStar_Syntax_Syntax.Delta_abstract (d) -> begin
(aux d)
end))
in (aux d))))


let compile_op : Prims.int  ->  Prims.string  ->  Prims.string = (fun arity s -> (

let name_of_char = (fun _63_5 -> (match (_63_5) with
| '&' -> begin
"Amp"
end
| '@' -> begin
"At"
end
| '+' -> begin
"Plus"
end
| '-' when (arity = 1) -> begin
"Minus"
end
| '-' -> begin
"Subtraction"
end
| '/' -> begin
"Slash"
end
| '<' -> begin
"Less"
end
| '=' -> begin
"Equals"
end
| '>' -> begin
"Greater"
end
| '_' -> begin
"Underscore"
end
| '|' -> begin
"Bar"
end
| '!' -> begin
"Bang"
end
| '^' -> begin
"Hat"
end
| '%' -> begin
"Percent"
end
| '*' -> begin
"Star"
end
| '?' -> begin
"Question"
end
| ':' -> begin
"Colon"
end
| _63_174 -> begin
"UNKNOWN"
end))
in (

let rec aux = (fun i -> if (i = (FStar_String.length s)) then begin
[]
end else begin
(let _154_47 = (let _154_45 = (FStar_Util.char_at s i)
in (name_of_char _154_45))
in (let _154_46 = (aux (i + 1))
in (_154_47)::_154_46))
end)
in (let _154_49 = (let _154_48 = (aux 0)
in (FStar_String.concat "_" _154_48))
in (Prims.strcat "op_" _154_49)))))


let compile_op_lid : Prims.int  ->  Prims.string  ->  FStar_Range.range  ->  FStar_Ident.lident = (fun n s r -> (let _154_59 = (let _154_58 = (let _154_57 = (let _154_56 = (compile_op n s)
in (_154_56, r))
in (FStar_Ident.mk_ident _154_57))
in (_154_58)::[])
in (FStar_All.pipe_right _154_59 FStar_Ident.lid_of_ids)))


let op_as_term : FStar_Parser_Env.env  ->  Prims.int  ->  FStar_Range.range  ->  Prims.string  ->  FStar_Syntax_Syntax.term Prims.option = (fun env arity rng s -> (

let r = (fun l dd -> (let _154_74 = (let _154_73 = (let _154_72 = (FStar_Ident.set_lid_range l rng)
in (FStar_Syntax_Syntax.lid_as_fv _154_72 dd None))
in (FStar_All.pipe_right _154_73 FStar_Syntax_Syntax.fv_to_tm))
in Some (_154_74)))
in (

let fallback = (fun _63_189 -> (match (()) with
| () -> begin
(match (s) with
| "=" -> begin
(r FStar_Syntax_Const.op_Eq FStar_Syntax_Syntax.Delta_equational)
end
| ":=" -> begin
(r FStar_Syntax_Const.op_ColonEq FStar_Syntax_Syntax.Delta_equational)
end
| "<" -> begin
(r FStar_Syntax_Const.op_LT FStar_Syntax_Syntax.Delta_equational)
end
| "<=" -> begin
(r FStar_Syntax_Const.op_LTE FStar_Syntax_Syntax.Delta_equational)
end
| ">" -> begin
(r FStar_Syntax_Const.op_GT FStar_Syntax_Syntax.Delta_equational)
end
| ">=" -> begin
(r FStar_Syntax_Const.op_GTE FStar_Syntax_Syntax.Delta_equational)
end
| "&&" -> begin
(r FStar_Syntax_Const.op_And FStar_Syntax_Syntax.Delta_equational)
end
| "||" -> begin
(r FStar_Syntax_Const.op_Or FStar_Syntax_Syntax.Delta_equational)
end
| "+" -> begin
(r FStar_Syntax_Const.op_Addition FStar_Syntax_Syntax.Delta_equational)
end
| "-" when (arity = 1) -> begin
(r FStar_Syntax_Const.op_Minus FStar_Syntax_Syntax.Delta_equational)
end
| "-" -> begin
(r FStar_Syntax_Const.op_Subtraction FStar_Syntax_Syntax.Delta_equational)
end
| "/" -> begin
(r FStar_Syntax_Const.op_Division FStar_Syntax_Syntax.Delta_equational)
end
| "%" -> begin
(r FStar_Syntax_Const.op_Modulus FStar_Syntax_Syntax.Delta_equational)
end
| "!" -> begin
(r FStar_Syntax_Const.read_lid FStar_Syntax_Syntax.Delta_equational)
end
| "@" -> begin
(r FStar_Syntax_Const.list_append_lid FStar_Syntax_Syntax.Delta_equational)
end
| "^" -> begin
(r FStar_Syntax_Const.strcat_lid FStar_Syntax_Syntax.Delta_equational)
end
| "|>" -> begin
(r FStar_Syntax_Const.pipe_right_lid FStar_Syntax_Syntax.Delta_equational)
end
| "<|" -> begin
(r FStar_Syntax_Const.pipe_left_lid FStar_Syntax_Syntax.Delta_equational)
end
| "<>" -> begin
(r FStar_Syntax_Const.op_notEq FStar_Syntax_Syntax.Delta_equational)
end
| "~" -> begin
(r FStar_Syntax_Const.not_lid (FStar_Syntax_Syntax.Delta_unfoldable (2)))
end
| "==" -> begin
(r FStar_Syntax_Const.eq2_lid FStar_Syntax_Syntax.Delta_constant)
end
| "<<" -> begin
(r FStar_Syntax_Const.precedes_lid FStar_Syntax_Syntax.Delta_constant)
end
| "/\\" -> begin
(r FStar_Syntax_Const.and_lid (FStar_Syntax_Syntax.Delta_unfoldable (1)))
end
| "\\/" -> begin
(r FStar_Syntax_Const.or_lid (FStar_Syntax_Syntax.Delta_unfoldable (1)))
end
| "==>" -> begin
(r FStar_Syntax_Const.imp_lid (FStar_Syntax_Syntax.Delta_unfoldable (1)))
end
| "<==>" -> begin
(r FStar_Syntax_Const.iff_lid (FStar_Syntax_Syntax.Delta_unfoldable (2)))
end
| _63_217 -> begin
None
end)
end))
in (match ((let _154_77 = (compile_op_lid arity s rng)
in (FStar_Parser_Env.try_lookup_lid env _154_77))) with
| Some (t) -> begin
Some ((Prims.fst t))
end
| _63_221 -> begin
(fallback ())
end))))


let sort_ftv : FStar_Ident.ident Prims.list  ->  FStar_Ident.ident Prims.list = (fun ftv -> (let _154_84 = (FStar_Util.remove_dups (fun x y -> (x.FStar_Ident.idText = y.FStar_Ident.idText)) ftv)
in (FStar_All.pipe_left (FStar_Util.sort_with (fun x y -> (FStar_String.compare x.FStar_Ident.idText y.FStar_Ident.idText))) _154_84)))


let rec free_type_vars_b : FStar_Parser_Env.env  ->  FStar_Parser_AST.binder  ->  (FStar_Parser_Env.env * FStar_Ident.ident Prims.list) = (fun env binder -> (match (binder.FStar_Parser_AST.b) with
| FStar_Parser_AST.Variable (_63_230) -> begin
(env, [])
end
| FStar_Parser_AST.TVariable (x) -> begin
(

let _63_237 = (FStar_Parser_Env.push_bv env x)
in (match (_63_237) with
| (env, _63_236) -> begin
(env, (x)::[])
end))
end
| FStar_Parser_AST.Annotated (_63_239, term) -> begin
(let _154_91 = (free_type_vars env term)
in (env, _154_91))
end
| FStar_Parser_AST.TAnnotated (id, _63_245) -> begin
(

let _63_251 = (FStar_Parser_Env.push_bv env id)
in (match (_63_251) with
| (env, _63_250) -> begin
(env, [])
end))
end
| FStar_Parser_AST.NoName (t) -> begin
(let _154_92 = (free_type_vars env t)
in (env, _154_92))
end))
and free_type_vars : FStar_Parser_Env.env  ->  FStar_Parser_AST.term  ->  FStar_Ident.ident Prims.list = (fun env t -> (match ((let _154_95 = (unparen t)
in _154_95.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Labeled (_63_257) -> begin
(FStar_All.failwith "Impossible --- labeled source term")
end
| FStar_Parser_AST.Tvar (a) -> begin
(match ((FStar_Parser_Env.try_lookup_id env a)) with
| None -> begin
(a)::[]
end
| _63_263 -> begin
[]
end)
end
| (FStar_Parser_AST.Wild) | (FStar_Parser_AST.Const (_)) | (FStar_Parser_AST.Var (_)) | (FStar_Parser_AST.Name (_)) -> begin
[]
end
| (FStar_Parser_AST.Assign (_, t)) | (FStar_Parser_AST.Requires (t, _)) | (FStar_Parser_AST.Ensures (t, _)) | (FStar_Parser_AST.NamedTyp (_, t)) | (FStar_Parser_AST.Paren (t)) | (FStar_Parser_AST.Ascribed (t, _)) -> begin
(free_type_vars env t)
end
| FStar_Parser_AST.Construct (_63_297, ts) -> begin
(FStar_List.collect (fun _63_304 -> (match (_63_304) with
| (t, _63_303) -> begin
(free_type_vars env t)
end)) ts)
end
| FStar_Parser_AST.Op (_63_306, ts) -> begin
(FStar_List.collect (free_type_vars env) ts)
end
| FStar_Parser_AST.App (t1, t2, _63_313) -> begin
(let _154_98 = (free_type_vars env t1)
in (let _154_97 = (free_type_vars env t2)
in (FStar_List.append _154_98 _154_97)))
end
| FStar_Parser_AST.Refine (b, t) -> begin
(

let _63_322 = (free_type_vars_b env b)
in (match (_63_322) with
| (env, f) -> begin
(let _154_99 = (free_type_vars env t)
in (FStar_List.append f _154_99))
end))
end
| (FStar_Parser_AST.Product (binders, body)) | (FStar_Parser_AST.Sum (binders, body)) -> begin
(

let _63_338 = (FStar_List.fold_left (fun _63_331 binder -> (match (_63_331) with
| (env, free) -> begin
(

let _63_335 = (free_type_vars_b env binder)
in (match (_63_335) with
| (env, f) -> begin
(env, (FStar_List.append f free))
end))
end)) (env, []) binders)
in (match (_63_338) with
| (env, free) -> begin
(let _154_102 = (free_type_vars env body)
in (FStar_List.append free _154_102))
end))
end
| FStar_Parser_AST.Project (t, _63_341) -> begin
(free_type_vars env t)
end
| (FStar_Parser_AST.Abs (_)) | (FStar_Parser_AST.Let (_)) | (FStar_Parser_AST.If (_)) | (FStar_Parser_AST.QForall (_)) | (FStar_Parser_AST.QExists (_)) | (FStar_Parser_AST.Record (_)) | (FStar_Parser_AST.Match (_)) | (FStar_Parser_AST.TryWith (_)) | (FStar_Parser_AST.Seq (_)) -> begin
[]
end))


let head_and_args : FStar_Parser_AST.term  ->  (FStar_Parser_AST.term * (FStar_Parser_AST.term * FStar_Parser_AST.imp) Prims.list) = (fun t -> (

let rec aux = (fun args t -> (match ((let _154_109 = (unparen t)
in _154_109.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.App (t, arg, imp) -> begin
(aux (((arg, imp))::args) t)
end
| FStar_Parser_AST.Construct (l, args') -> begin
({FStar_Parser_AST.tm = FStar_Parser_AST.Name (l); FStar_Parser_AST.range = t.FStar_Parser_AST.range; FStar_Parser_AST.level = t.FStar_Parser_AST.level}, (FStar_List.append args' args))
end
| _63_385 -> begin
(t, args)
end))
in (aux [] t)))


let close : FStar_Parser_Env.env  ->  FStar_Parser_AST.term  ->  FStar_Parser_AST.term = (fun env t -> (

let ftv = (let _154_114 = (free_type_vars env t)
in (FStar_All.pipe_left sort_ftv _154_114))
in if ((FStar_List.length ftv) = 0) then begin
t
end else begin
(

let binders = (FStar_All.pipe_right ftv (FStar_List.map (fun x -> (let _154_118 = (let _154_117 = (let _154_116 = (tm_type x.FStar_Ident.idRange)
in (x, _154_116))
in FStar_Parser_AST.TAnnotated (_154_117))
in (FStar_Parser_AST.mk_binder _154_118 x.FStar_Ident.idRange FStar_Parser_AST.Type (Some (FStar_Parser_AST.Implicit)))))))
in (

let result = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Product ((binders, t))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)
in result))
end))


let close_fun : FStar_Parser_Env.env  ->  FStar_Parser_AST.term  ->  FStar_Parser_AST.term = (fun env t -> (

let ftv = (let _154_123 = (free_type_vars env t)
in (FStar_All.pipe_left sort_ftv _154_123))
in if ((FStar_List.length ftv) = 0) then begin
t
end else begin
(

let binders = (FStar_All.pipe_right ftv (FStar_List.map (fun x -> (let _154_127 = (let _154_126 = (let _154_125 = (tm_type x.FStar_Ident.idRange)
in (x, _154_125))
in FStar_Parser_AST.TAnnotated (_154_126))
in (FStar_Parser_AST.mk_binder _154_127 x.FStar_Ident.idRange FStar_Parser_AST.Type (Some (FStar_Parser_AST.Implicit)))))))
in (

let t = (match ((let _154_128 = (unparen t)
in _154_128.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Product (_63_398) -> begin
t
end
| _63_401 -> begin
(FStar_Parser_AST.mk_term (FStar_Parser_AST.App (((FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Syntax_Const.effect_Tot_lid)) t.FStar_Parser_AST.range t.FStar_Parser_AST.level), t, FStar_Parser_AST.Nothing))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)
end)
in (

let result = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Product ((binders, t))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)
in result)))
end))


let rec uncurry : FStar_Parser_AST.binder Prims.list  ->  FStar_Parser_AST.term  ->  (FStar_Parser_AST.binder Prims.list * FStar_Parser_AST.term) = (fun bs t -> (match (t.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Product (binders, t) -> begin
(uncurry (FStar_List.append bs binders) t)
end
| _63_411 -> begin
(bs, t)
end))


let rec is_app_pattern : FStar_Parser_AST.pattern  ->  Prims.bool = (fun p -> (match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatAscribed (p, _63_415) -> begin
(is_app_pattern p)
end
| FStar_Parser_AST.PatApp ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (_63_421); FStar_Parser_AST.prange = _63_419}, _63_425) -> begin
true
end
| _63_429 -> begin
false
end))


let rec destruct_app_pattern : FStar_Parser_Env.env  ->  Prims.bool  ->  FStar_Parser_AST.pattern  ->  ((FStar_Ident.ident, FStar_Ident.lident) FStar_Util.either * FStar_Parser_AST.pattern Prims.list * FStar_Parser_AST.term Prims.option) = (fun env is_top_level p -> (match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatAscribed (p, t) -> begin
(

let _63_441 = (destruct_app_pattern env is_top_level p)
in (match (_63_441) with
| (name, args, _63_440) -> begin
(name, args, Some (t))
end))
end
| FStar_Parser_AST.PatApp ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (id, _63_446); FStar_Parser_AST.prange = _63_443}, args) when is_top_level -> begin
(let _154_142 = (let _154_141 = (FStar_Parser_Env.qualify env id)
in FStar_Util.Inr (_154_141))
in (_154_142, args, None))
end
| FStar_Parser_AST.PatApp ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (id, _63_457); FStar_Parser_AST.prange = _63_454}, args) -> begin
(FStar_Util.Inl (id), args, None)
end
| _63_465 -> begin
(FStar_All.failwith "Not an app pattern")
end))


type bnd =
| LocalBinder of (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.aqual)
| LetBinder of (FStar_Ident.lident * FStar_Syntax_Syntax.term)


let is_LocalBinder = (fun _discr_ -> (match (_discr_) with
| LocalBinder (_) -> begin
true
end
| _ -> begin
false
end))


let is_LetBinder = (fun _discr_ -> (match (_discr_) with
| LetBinder (_) -> begin
true
end
| _ -> begin
false
end))


let ___LocalBinder____0 = (fun projectee -> (match (projectee) with
| LocalBinder (_63_468) -> begin
_63_468
end))


let ___LetBinder____0 = (fun projectee -> (match (projectee) with
| LetBinder (_63_471) -> begin
_63_471
end))


let binder_of_bnd : bnd  ->  (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.aqual) = (fun _63_6 -> (match (_63_6) with
| LocalBinder (a, aq) -> begin
(a, aq)
end
| _63_478 -> begin
(FStar_All.failwith "Impossible")
end))


let as_binder : FStar_Parser_Env.env  ->  FStar_Parser_AST.arg_qualifier Prims.option  ->  (FStar_Ident.ident Prims.option * FStar_Syntax_Syntax.term)  ->  (FStar_Syntax_Syntax.binder * FStar_Parser_Env.env) = (fun env imp _63_7 -> (match (_63_7) with
| (None, k) -> begin
(let _154_179 = (FStar_Syntax_Syntax.null_binder k)
in (_154_179, env))
end
| (Some (a), k) -> begin
(

let _63_491 = (FStar_Parser_Env.push_bv env a)
in (match (_63_491) with
| (env, a) -> begin
(((

let _63_492 = a
in {FStar_Syntax_Syntax.ppname = _63_492.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = _63_492.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = k}), (trans_aqual imp)), env)
end))
end))


type env_t =
FStar_Parser_Env.env


type lenv_t =
FStar_Syntax_Syntax.bv Prims.list


let mk_lb : (FStar_Syntax_Syntax.lbname * FStar_Syntax_Syntax.typ * FStar_Syntax_Syntax.term)  ->  FStar_Syntax_Syntax.letbinding = (fun _63_497 -> (match (_63_497) with
| (n, t, e) -> begin
{FStar_Syntax_Syntax.lbname = n; FStar_Syntax_Syntax.lbunivs = []; FStar_Syntax_Syntax.lbtyp = t; FStar_Syntax_Syntax.lbeff = FStar_Syntax_Const.effect_ALL_lid; FStar_Syntax_Syntax.lbdef = e}
end))


let no_annot_abs : (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list  ->  FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.term = (fun bs t -> (FStar_Syntax_Util.abs bs t None))


let mk_ref_read = (fun tm -> (

let tm' = (let _154_192 = (let _154_191 = (let _154_187 = (FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.sread_lid FStar_Syntax_Syntax.Delta_constant None)
in (FStar_Syntax_Syntax.fv_to_tm _154_187))
in (let _154_190 = (let _154_189 = (let _154_188 = (FStar_Syntax_Syntax.as_implicit false)
in (tm, _154_188))
in (_154_189)::[])
in (_154_191, _154_190)))
in FStar_Syntax_Syntax.Tm_app (_154_192))
in (FStar_Syntax_Syntax.mk tm' None tm.FStar_Syntax_Syntax.pos)))


let mk_ref_alloc = (fun tm -> (

let tm' = (let _154_199 = (let _154_198 = (let _154_194 = (FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.salloc_lid FStar_Syntax_Syntax.Delta_constant None)
in (FStar_Syntax_Syntax.fv_to_tm _154_194))
in (let _154_197 = (let _154_196 = (let _154_195 = (FStar_Syntax_Syntax.as_implicit false)
in (tm, _154_195))
in (_154_196)::[])
in (_154_198, _154_197)))
in FStar_Syntax_Syntax.Tm_app (_154_199))
in (FStar_Syntax_Syntax.mk tm' None tm.FStar_Syntax_Syntax.pos)))


let mk_ref_assign = (fun t1 t2 pos -> (

let tm = (let _154_211 = (let _154_210 = (let _154_203 = (FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.swrite_lid FStar_Syntax_Syntax.Delta_constant None)
in (FStar_Syntax_Syntax.fv_to_tm _154_203))
in (let _154_209 = (let _154_208 = (let _154_204 = (FStar_Syntax_Syntax.as_implicit false)
in (t1, _154_204))
in (let _154_207 = (let _154_206 = (let _154_205 = (FStar_Syntax_Syntax.as_implicit false)
in (t2, _154_205))
in (_154_206)::[])
in (_154_208)::_154_207))
in (_154_210, _154_209)))
in FStar_Syntax_Syntax.Tm_app (_154_211))
in (FStar_Syntax_Syntax.mk tm None pos)))


let rec desugar_data_pat : FStar_Parser_Env.env  ->  FStar_Parser_AST.pattern  ->  Prims.bool  ->  (env_t * bnd * FStar_Syntax_Syntax.pat) = (fun env p is_mut -> (

let check_linear_pattern_variables = (fun p -> (

let rec pat_vars = (fun p -> (match (p.FStar_Syntax_Syntax.v) with
| (FStar_Syntax_Syntax.Pat_dot_term (_)) | (FStar_Syntax_Syntax.Pat_wild (_)) | (FStar_Syntax_Syntax.Pat_constant (_)) -> begin
FStar_Syntax_Syntax.no_names
end
| FStar_Syntax_Syntax.Pat_var (x) -> begin
(FStar_Util.set_add x FStar_Syntax_Syntax.no_names)
end
| FStar_Syntax_Syntax.Pat_cons (_63_527, pats) -> begin
(FStar_All.pipe_right pats (FStar_List.fold_left (fun out _63_535 -> (match (_63_535) with
| (p, _63_534) -> begin
(let _154_258 = (pat_vars p)
in (FStar_Util.set_union out _154_258))
end)) FStar_Syntax_Syntax.no_names))
end
| FStar_Syntax_Syntax.Pat_disj ([]) -> begin
(FStar_All.failwith "Impossible")
end
| FStar_Syntax_Syntax.Pat_disj ((hd)::tl) -> begin
(

let xs = (pat_vars hd)
in if (not ((FStar_Util.for_all (fun p -> (

let ys = (pat_vars p)
in ((FStar_Util.set_is_subset_of xs ys) && (FStar_Util.set_is_subset_of ys xs)))) tl))) then begin
(Prims.raise (FStar_Syntax_Syntax.Error (("Disjunctive pattern binds different variables in each case", p.FStar_Syntax_Syntax.p))))
end else begin
xs
end)
end))
in (pat_vars p)))
in (

let _63_558 = (match ((is_mut, p.FStar_Parser_AST.pat)) with
| ((false, _)) | ((true, FStar_Parser_AST.PatVar (_))) -> begin
()
end
| (true, _63_556) -> begin
(Prims.raise (FStar_Syntax_Syntax.Error (("let-mutable is for variables only", p.FStar_Parser_AST.prange))))
end)
in (

let push_bv_maybe_mut = if is_mut then begin
FStar_Parser_Env.push_bv_mutable
end else begin
FStar_Parser_Env.push_bv
end
in (

let resolvex = (fun l e x -> (match ((FStar_All.pipe_right l (FStar_Util.find_opt (fun y -> (y.FStar_Syntax_Syntax.ppname.FStar_Ident.idText = x.FStar_Ident.idText))))) with
| Some (y) -> begin
(l, e, y)
end
| _63_569 -> begin
(

let _63_572 = (push_bv_maybe_mut e x)
in (match (_63_572) with
| (e, x) -> begin
((x)::l, e, x)
end))
end))
in (

let resolvea = (fun l e a -> (match ((FStar_All.pipe_right l (FStar_Util.find_opt (fun b -> (b.FStar_Syntax_Syntax.ppname.FStar_Ident.idText = a.FStar_Ident.idText))))) with
| Some (b) -> begin
(l, e, b)
end
| _63_581 -> begin
(

let _63_584 = (push_bv_maybe_mut e a)
in (match (_63_584) with
| (e, a) -> begin
((a)::l, e, a)
end))
end))
in (

let rec aux = (fun loc env p -> (

let pos = (fun q -> (FStar_Syntax_Syntax.withinfo q FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n p.FStar_Parser_AST.prange))
in (

let pos_r = (fun r q -> (FStar_Syntax_Syntax.withinfo q FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n r))
in (match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatOr ([]) -> begin
(FStar_All.failwith "impossible")
end
| FStar_Parser_AST.PatOr ((p)::ps) -> begin
(

let _63_606 = (aux loc env p)
in (match (_63_606) with
| (loc, env, var, p, _63_605) -> begin
(

let _63_623 = (FStar_List.fold_left (fun _63_610 p -> (match (_63_610) with
| (loc, env, ps) -> begin
(

let _63_619 = (aux loc env p)
in (match (_63_619) with
| (loc, env, _63_615, p, _63_618) -> begin
(loc, env, (p)::ps)
end))
end)) (loc, env, []) ps)
in (match (_63_623) with
| (loc, env, ps) -> begin
(

let pat = (FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_disj ((p)::(FStar_List.rev ps))))
in (loc, env, var, pat, false))
end))
end))
end
| FStar_Parser_AST.PatAscribed (p, t) -> begin
(

let _63_634 = (aux loc env p)
in (match (_63_634) with
| (loc, env', binder, p, imp) -> begin
(

let binder = (match (binder) with
| LetBinder (_63_636) -> begin
(FStar_All.failwith "impossible")
end
| LocalBinder (x, aq) -> begin
(

let t = (let _154_292 = (close_fun env t)
in (desugar_term env _154_292))
in LocalBinder (((

let _63_643 = x
in {FStar_Syntax_Syntax.ppname = _63_643.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = _63_643.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = t}), aq)))
end)
in (loc, env', binder, p, imp))
end))
end
| FStar_Parser_AST.PatWild -> begin
(

let x = (FStar_Syntax_Syntax.new_bv (Some (p.FStar_Parser_AST.prange)) FStar_Syntax_Syntax.tun)
in (let _154_293 = (FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_wild (x)))
in (loc, env, LocalBinder ((x, None)), _154_293, false)))
end
| FStar_Parser_AST.PatConst (c) -> begin
(

let x = (FStar_Syntax_Syntax.new_bv (Some (p.FStar_Parser_AST.prange)) FStar_Syntax_Syntax.tun)
in (let _154_294 = (FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_constant (c)))
in (loc, env, LocalBinder ((x, None)), _154_294, false)))
end
| (FStar_Parser_AST.PatTvar (x, aq)) | (FStar_Parser_AST.PatVar (x, aq)) -> begin
(

let imp = (aq = Some (FStar_Parser_AST.Implicit))
in (

let aq = (trans_aqual aq)
in (

let _63_662 = (resolvex loc env x)
in (match (_63_662) with
| (loc, env, xbv) -> begin
(let _154_295 = (FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_var (xbv)))
in (loc, env, LocalBinder ((xbv, aq)), _154_295, imp))
end))))
end
| FStar_Parser_AST.PatName (l) -> begin
(

let l = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_datacon env) l)
in (

let x = (FStar_Syntax_Syntax.new_bv (Some (p.FStar_Parser_AST.prange)) FStar_Syntax_Syntax.tun)
in (let _154_296 = (FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_cons ((l, []))))
in (loc, env, LocalBinder ((x, None)), _154_296, false))))
end
| FStar_Parser_AST.PatApp ({FStar_Parser_AST.pat = FStar_Parser_AST.PatName (l); FStar_Parser_AST.prange = _63_668}, args) -> begin
(

let _63_690 = (FStar_List.fold_right (fun arg _63_679 -> (match (_63_679) with
| (loc, env, args) -> begin
(

let _63_686 = (aux loc env arg)
in (match (_63_686) with
| (loc, env, _63_683, arg, imp) -> begin
(loc, env, ((arg, imp))::args)
end))
end)) args (loc, env, []))
in (match (_63_690) with
| (loc, env, args) -> begin
(

let l = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_datacon env) l)
in (

let x = (FStar_Syntax_Syntax.new_bv (Some (p.FStar_Parser_AST.prange)) FStar_Syntax_Syntax.tun)
in (let _154_299 = (FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_cons ((l, args))))
in (loc, env, LocalBinder ((x, None)), _154_299, false))))
end))
end
| FStar_Parser_AST.PatApp (_63_694) -> begin
(Prims.raise (FStar_Syntax_Syntax.Error (("Unexpected pattern", p.FStar_Parser_AST.prange))))
end
| FStar_Parser_AST.PatList (pats) -> begin
(

let _63_714 = (FStar_List.fold_right (fun pat _63_702 -> (match (_63_702) with
| (loc, env, pats) -> begin
(

let _63_710 = (aux loc env pat)
in (match (_63_710) with
| (loc, env, _63_706, pat, _63_709) -> begin
(loc, env, (pat)::pats)
end))
end)) pats (loc, env, []))
in (match (_63_714) with
| (loc, env, pats) -> begin
(

let pat = (let _154_312 = (let _154_311 = (let _154_307 = (FStar_Range.end_range p.FStar_Parser_AST.prange)
in (pos_r _154_307))
in (let _154_310 = (let _154_309 = (let _154_308 = (FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.nil_lid FStar_Syntax_Syntax.Delta_constant (Some (FStar_Syntax_Syntax.Data_ctor)))
in (_154_308, []))
in FStar_Syntax_Syntax.Pat_cons (_154_309))
in (FStar_All.pipe_left _154_311 _154_310)))
in (FStar_List.fold_right (fun hd tl -> (

let r = (FStar_Range.union_ranges hd.FStar_Syntax_Syntax.p tl.FStar_Syntax_Syntax.p)
in (let _154_306 = (let _154_305 = (let _154_304 = (FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.cons_lid FStar_Syntax_Syntax.Delta_constant (Some (FStar_Syntax_Syntax.Data_ctor)))
in (_154_304, ((hd, false))::((tl, false))::[]))
in FStar_Syntax_Syntax.Pat_cons (_154_305))
in (FStar_All.pipe_left (pos_r r) _154_306)))) pats _154_312))
in (

let x = (FStar_Syntax_Syntax.new_bv (Some (p.FStar_Parser_AST.prange)) FStar_Syntax_Syntax.tun)
in (loc, env, LocalBinder ((x, None)), pat, false)))
end))
end
| FStar_Parser_AST.PatTuple (args, dep) -> begin
(

let _63_740 = (FStar_List.fold_left (fun _63_727 p -> (match (_63_727) with
| (loc, env, pats) -> begin
(

let _63_736 = (aux loc env p)
in (match (_63_736) with
| (loc, env, _63_732, pat, _63_735) -> begin
(loc, env, ((pat, false))::pats)
end))
end)) (loc, env, []) args)
in (match (_63_740) with
| (loc, env, args) -> begin
(

let args = (FStar_List.rev args)
in (

let l = if dep then begin
(FStar_Syntax_Util.mk_dtuple_data_lid (FStar_List.length args) p.FStar_Parser_AST.prange)
end else begin
(FStar_Syntax_Util.mk_tuple_data_lid (FStar_List.length args) p.FStar_Parser_AST.prange)
end
in (

let _63_746 = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_lid env) l)
in (match (_63_746) with
| (constr, _63_745) -> begin
(

let l = (match (constr.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_fvar (fv) -> begin
fv
end
| _63_750 -> begin
(FStar_All.failwith "impossible")
end)
in (

let x = (FStar_Syntax_Syntax.new_bv (Some (p.FStar_Parser_AST.prange)) FStar_Syntax_Syntax.tun)
in (let _154_315 = (FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_cons ((l, args))))
in (loc, env, LocalBinder ((x, None)), _154_315, false))))
end))))
end))
end
| FStar_Parser_AST.PatRecord ([]) -> begin
(Prims.raise (FStar_Syntax_Syntax.Error (("Unexpected pattern", p.FStar_Parser_AST.prange))))
end
| FStar_Parser_AST.PatRecord (fields) -> begin
(

let _63_760 = (FStar_List.hd fields)
in (match (_63_760) with
| (f, _63_759) -> begin
(

let _63_764 = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_record_by_field_name env) f)
in (match (_63_764) with
| (record, _63_763) -> begin
(

let fields = (FStar_All.pipe_right fields (FStar_List.map (fun _63_767 -> (match (_63_767) with
| (f, p) -> begin
(let _154_317 = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.qualify_field_to_record env record) f)
in (_154_317, p))
end))))
in (

let args = (FStar_All.pipe_right record.FStar_Parser_Env.fields (FStar_List.map (fun _63_772 -> (match (_63_772) with
| (f, _63_771) -> begin
(match ((FStar_All.pipe_right fields (FStar_List.tryFind (fun _63_776 -> (match (_63_776) with
| (g, _63_775) -> begin
(FStar_Ident.lid_equals f g)
end))))) with
| None -> begin
(FStar_Parser_AST.mk_pattern FStar_Parser_AST.PatWild p.FStar_Parser_AST.prange)
end
| Some (_63_779, p) -> begin
p
end)
end))))
in (

let app = (FStar_Parser_AST.mk_pattern (FStar_Parser_AST.PatApp (((FStar_Parser_AST.mk_pattern (FStar_Parser_AST.PatName (record.FStar_Parser_Env.constrname)) p.FStar_Parser_AST.prange), args))) p.FStar_Parser_AST.prange)
in (

let _63_791 = (aux loc env app)
in (match (_63_791) with
| (env, e, b, p, _63_790) -> begin
(

let p = (match (p.FStar_Syntax_Syntax.v) with
| FStar_Syntax_Syntax.Pat_cons (fv, args) -> begin
(let _154_326 = (let _154_325 = (let _154_324 = (

let _63_796 = fv
in (let _154_323 = (let _154_322 = (let _154_321 = (let _154_320 = (FStar_All.pipe_right record.FStar_Parser_Env.fields (FStar_List.map Prims.fst))
in (record.FStar_Parser_Env.typename, _154_320))
in FStar_Syntax_Syntax.Record_ctor (_154_321))
in Some (_154_322))
in {FStar_Syntax_Syntax.fv_name = _63_796.FStar_Syntax_Syntax.fv_name; FStar_Syntax_Syntax.fv_delta = _63_796.FStar_Syntax_Syntax.fv_delta; FStar_Syntax_Syntax.fv_qual = _154_323}))
in (_154_324, args))
in FStar_Syntax_Syntax.Pat_cons (_154_325))
in (FStar_All.pipe_left pos _154_326))
end
| _63_799 -> begin
p
end)
in (env, e, b, p, false))
end)))))
end))
end))
end))))
in (

let _63_808 = (aux [] env p)
in (match (_63_808) with
| (_63_802, env, b, p, _63_807) -> begin
(

let _63_809 = (let _154_327 = (check_linear_pattern_variables p)
in (FStar_All.pipe_left Prims.ignore _154_327))
in (env, b, p))
end)))))))))
and desugar_binding_pat_maybe_top : Prims.bool  ->  FStar_Parser_Env.env  ->  FStar_Parser_AST.pattern  ->  Prims.bool  ->  (env_t * bnd * FStar_Syntax_Syntax.pat Prims.option) = (fun top env p is_mut -> if top then begin
(match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatVar (x, _63_817) -> begin
(let _154_334 = (let _154_333 = (let _154_332 = (FStar_Parser_Env.qualify env x)
in (_154_332, FStar_Syntax_Syntax.tun))
in LetBinder (_154_333))
in (env, _154_334, None))
end
| FStar_Parser_AST.PatAscribed ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (x, _63_824); FStar_Parser_AST.prange = _63_821}, t) -> begin
(let _154_338 = (let _154_337 = (let _154_336 = (FStar_Parser_Env.qualify env x)
in (let _154_335 = (desugar_term env t)
in (_154_336, _154_335)))
in LetBinder (_154_337))
in (env, _154_338, None))
end
| _63_832 -> begin
(Prims.raise (FStar_Syntax_Syntax.Error (("Unexpected pattern at the top-level", p.FStar_Parser_AST.prange))))
end)
end else begin
(

let _63_836 = (desugar_data_pat env p is_mut)
in (match (_63_836) with
| (env, binder, p) -> begin
(

let p = (match (p.FStar_Syntax_Syntax.v) with
| (FStar_Syntax_Syntax.Pat_var (_)) | (FStar_Syntax_Syntax.Pat_wild (_)) -> begin
None
end
| _63_844 -> begin
Some (p)
end)
in (env, binder, p))
end))
end)
and desugar_binding_pat : FStar_Parser_Env.env  ->  FStar_Parser_AST.pattern  ->  (env_t * bnd * FStar_Syntax_Syntax.pat Prims.option) = (fun env p -> (desugar_binding_pat_maybe_top false env p false))
and desugar_match_pat_maybe_top : Prims.bool  ->  FStar_Parser_Env.env  ->  FStar_Parser_AST.pattern  ->  (env_t * FStar_Syntax_Syntax.pat) = (fun _63_848 env pat -> (

let _63_856 = (desugar_data_pat env pat false)
in (match (_63_856) with
| (env, _63_854, pat) -> begin
(env, pat)
end)))
and desugar_match_pat : FStar_Parser_Env.env  ->  FStar_Parser_AST.pattern  ->  (env_t * FStar_Syntax_Syntax.pat) = (fun env p -> (desugar_match_pat_maybe_top false env p))
and desugar_term : FStar_Parser_Env.env  ->  FStar_Parser_AST.term  ->  FStar_Syntax_Syntax.term = (fun env e -> (

let env = (

let _63_861 = env
in {FStar_Parser_Env.curmodule = _63_861.FStar_Parser_Env.curmodule; FStar_Parser_Env.modules = _63_861.FStar_Parser_Env.modules; FStar_Parser_Env.open_namespaces = _63_861.FStar_Parser_Env.open_namespaces; FStar_Parser_Env.modul_abbrevs = _63_861.FStar_Parser_Env.modul_abbrevs; FStar_Parser_Env.sigaccum = _63_861.FStar_Parser_Env.sigaccum; FStar_Parser_Env.localbindings = _63_861.FStar_Parser_Env.localbindings; FStar_Parser_Env.recbindings = _63_861.FStar_Parser_Env.recbindings; FStar_Parser_Env.sigmap = _63_861.FStar_Parser_Env.sigmap; FStar_Parser_Env.default_result_effect = _63_861.FStar_Parser_Env.default_result_effect; FStar_Parser_Env.iface = _63_861.FStar_Parser_Env.iface; FStar_Parser_Env.admitted_iface = _63_861.FStar_Parser_Env.admitted_iface; FStar_Parser_Env.expect_typ = false})
in (desugar_term_maybe_top false env e)))
and desugar_typ : FStar_Parser_Env.env  ->  FStar_Parser_AST.term  ->  FStar_Syntax_Syntax.term = (fun env e -> (

let env = (

let _63_866 = env
in {FStar_Parser_Env.curmodule = _63_866.FStar_Parser_Env.curmodule; FStar_Parser_Env.modules = _63_866.FStar_Parser_Env.modules; FStar_Parser_Env.open_namespaces = _63_866.FStar_Parser_Env.open_namespaces; FStar_Parser_Env.modul_abbrevs = _63_866.FStar_Parser_Env.modul_abbrevs; FStar_Parser_Env.sigaccum = _63_866.FStar_Parser_Env.sigaccum; FStar_Parser_Env.localbindings = _63_866.FStar_Parser_Env.localbindings; FStar_Parser_Env.recbindings = _63_866.FStar_Parser_Env.recbindings; FStar_Parser_Env.sigmap = _63_866.FStar_Parser_Env.sigmap; FStar_Parser_Env.default_result_effect = _63_866.FStar_Parser_Env.default_result_effect; FStar_Parser_Env.iface = _63_866.FStar_Parser_Env.iface; FStar_Parser_Env.admitted_iface = _63_866.FStar_Parser_Env.admitted_iface; FStar_Parser_Env.expect_typ = true})
in (desugar_term_maybe_top false env e)))
and desugar_machine_integer : FStar_Parser_Env.env  ->  Prims.string  ->  (FStar_Const.signedness * FStar_Const.width)  ->  FStar_Range.range  ->  (FStar_Syntax_Syntax.term', FStar_Syntax_Syntax.term') FStar_Syntax_Syntax.syntax = (fun env repr _63_873 range -> (match (_63_873) with
| (signedness, width) -> begin
(

let lid = (Prims.strcat (Prims.strcat (Prims.strcat (Prims.strcat (Prims.strcat (Prims.strcat "FStar." (match (signedness) with
| FStar_Const.Unsigned -> begin
"U"
end
| FStar_Const.Signed -> begin
""
end)) "Int") (match (width) with
| FStar_Const.Int8 -> begin
"8"
end
| FStar_Const.Int16 -> begin
"16"
end
| FStar_Const.Int32 -> begin
"32"
end
| FStar_Const.Int64 -> begin
"64"
end)) ".") (match (signedness) with
| FStar_Const.Unsigned -> begin
"u"
end
| FStar_Const.Signed -> begin
""
end)) "int_to_t")
in (

let lid = (FStar_Ident.lid_of_path (FStar_Ident.path_of_text lid) range)
in (

let lid = (match ((FStar_Parser_Env.try_lookup_lid env lid)) with
| Some (lid) -> begin
(Prims.fst lid)
end
| None -> begin
(let _154_354 = (FStar_Util.format1 "%s not in scope\n" (FStar_Ident.text_of_lid lid))
in (FStar_All.failwith _154_354))
end)
in (

let repr = (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_constant (FStar_Const.Const_int ((repr, None)))) None range)
in (let _154_359 = (let _154_358 = (let _154_357 = (let _154_356 = (let _154_355 = (FStar_Syntax_Syntax.as_implicit false)
in (repr, _154_355))
in (_154_356)::[])
in (lid, _154_357))
in FStar_Syntax_Syntax.Tm_app (_154_358))
in (FStar_Syntax_Syntax.mk _154_359 None range))))))
end))
and desugar_term_maybe_top : Prims.bool  ->  env_t  ->  FStar_Parser_AST.term  ->  FStar_Syntax_Syntax.term = (fun top_level env top -> (

let mk = (fun e -> (FStar_Syntax_Syntax.mk e None top.FStar_Parser_AST.range))
in (

let setpos = (fun e -> (

let _63_897 = e
in {FStar_Syntax_Syntax.n = _63_897.FStar_Syntax_Syntax.n; FStar_Syntax_Syntax.tk = _63_897.FStar_Syntax_Syntax.tk; FStar_Syntax_Syntax.pos = top.FStar_Parser_AST.range; FStar_Syntax_Syntax.vars = _63_897.FStar_Syntax_Syntax.vars}))
in (match ((let _154_367 = (unparen top)
in _154_367.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Wild -> begin
(setpos FStar_Syntax_Syntax.tun)
end
| FStar_Parser_AST.Labeled (_63_901) -> begin
(desugar_formula env top)
end
| FStar_Parser_AST.Requires (t, lopt) -> begin
(desugar_formula env t)
end
| FStar_Parser_AST.Ensures (t, lopt) -> begin
(desugar_formula env t)
end
| FStar_Parser_AST.Const (FStar_Const.Const_int (i, Some (size))) -> begin
(desugar_machine_integer env i size top.FStar_Parser_AST.range)
end
| FStar_Parser_AST.Const (c) -> begin
(mk (FStar_Syntax_Syntax.Tm_constant (c)))
end
| FStar_Parser_AST.Op ("=!=", args) -> begin
(desugar_term env (FStar_Parser_AST.mk_term (FStar_Parser_AST.Op (("~", ((FStar_Parser_AST.mk_term (FStar_Parser_AST.Op (("==", args))) top.FStar_Parser_AST.range top.FStar_Parser_AST.level))::[]))) top.FStar_Parser_AST.range top.FStar_Parser_AST.level))
end
| FStar_Parser_AST.Op ("*", (_63_927)::(_63_925)::[]) when (let _154_368 = (op_as_term env 2 top.FStar_Parser_AST.range "*")
in (FStar_All.pipe_right _154_368 FStar_Option.isNone)) -> begin
(

let rec flatten = (fun t -> (match (t.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Op ("*", (t1)::(t2)::[]) -> begin
(

let rest = (flatten t2)
in (t1)::rest)
end
| _63_941 -> begin
(t)::[]
end))
in (

let targs = (let _154_374 = (let _154_371 = (unparen top)
in (flatten _154_371))
in (FStar_All.pipe_right _154_374 (FStar_List.map (fun t -> (let _154_373 = (desugar_typ env t)
in (FStar_Syntax_Syntax.as_arg _154_373))))))
in (

let _63_947 = (let _154_375 = (FStar_Syntax_Util.mk_tuple_lid (FStar_List.length targs) top.FStar_Parser_AST.range)
in (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_lid env) _154_375))
in (match (_63_947) with
| (tup, _63_946) -> begin
(mk (FStar_Syntax_Syntax.Tm_app ((tup, targs))))
end))))
end
| FStar_Parser_AST.Tvar (a) -> begin
(let _154_377 = (let _154_376 = (FStar_Parser_Env.fail_or2 (FStar_Parser_Env.try_lookup_id env) a)
in (Prims.fst _154_376))
in (FStar_All.pipe_left setpos _154_377))
end
| FStar_Parser_AST.Op (s, args) -> begin
(match ((op_as_term env (FStar_List.length args) top.FStar_Parser_AST.range s)) with
| None -> begin
(Prims.raise (FStar_Syntax_Syntax.Error (((Prims.strcat "Unexpected operator: " s), top.FStar_Parser_AST.range))))
end
| Some (op) -> begin
(

let args = (FStar_All.pipe_right args (FStar_List.map (fun t -> (let _154_379 = (desugar_term env t)
in (_154_379, None)))))
in (mk (FStar_Syntax_Syntax.Tm_app ((op, args)))))
end)
end
| FStar_Parser_AST.Name ({FStar_Ident.ns = _63_965; FStar_Ident.ident = _63_963; FStar_Ident.nsstr = _63_961; FStar_Ident.str = "Type0"}) -> begin
(mk (FStar_Syntax_Syntax.Tm_type (FStar_Syntax_Syntax.U_zero)))
end
| FStar_Parser_AST.Name ({FStar_Ident.ns = _63_974; FStar_Ident.ident = _63_972; FStar_Ident.nsstr = _63_970; FStar_Ident.str = "Type"}) -> begin
(mk (FStar_Syntax_Syntax.Tm_type (FStar_Syntax_Syntax.U_unknown)))
end
| FStar_Parser_AST.Name ({FStar_Ident.ns = _63_983; FStar_Ident.ident = _63_981; FStar_Ident.nsstr = _63_979; FStar_Ident.str = "Effect"}) -> begin
(mk (FStar_Syntax_Syntax.Tm_constant (FStar_Const.Const_effect)))
end
| FStar_Parser_AST.Name ({FStar_Ident.ns = _63_992; FStar_Ident.ident = _63_990; FStar_Ident.nsstr = _63_988; FStar_Ident.str = "True"}) -> begin
(let _154_380 = (FStar_Ident.set_lid_range FStar_Syntax_Const.true_lid top.FStar_Parser_AST.range)
in (FStar_Syntax_Syntax.fvar _154_380 FStar_Syntax_Syntax.Delta_constant None))
end
| FStar_Parser_AST.Name ({FStar_Ident.ns = _63_1001; FStar_Ident.ident = _63_999; FStar_Ident.nsstr = _63_997; FStar_Ident.str = "False"}) -> begin
(let _154_381 = (FStar_Ident.set_lid_range FStar_Syntax_Const.false_lid top.FStar_Parser_AST.range)
in (FStar_Syntax_Syntax.fvar _154_381 FStar_Syntax_Syntax.Delta_constant None))
end
| FStar_Parser_AST.Assign (ident, t2) -> begin
(

let t2 = (desugar_term env t2)
in (

let _63_1011 = (FStar_Parser_Env.fail_or2 (FStar_Parser_Env.try_lookup_id env) ident)
in (match (_63_1011) with
| (t1, mut) -> begin
(

let _63_1012 = if (not (mut)) then begin
(Prims.raise (FStar_Syntax_Syntax.Error (("Can only assign to mutable values", top.FStar_Parser_AST.range))))
end else begin
()
end
in (mk_ref_assign t1 t2 top.FStar_Parser_AST.range))
end)))
end
| (FStar_Parser_AST.Var (l)) | (FStar_Parser_AST.Name (l)) -> begin
(

let _63_1019 = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_lid env) l)
in (match (_63_1019) with
| (tm, mut) -> begin
(

let tm = (setpos tm)
in if mut then begin
(let _154_384 = (let _154_383 = (let _154_382 = (mk_ref_read tm)
in (_154_382, FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Mutable_rval)))
in FStar_Syntax_Syntax.Tm_meta (_154_383))
in (FStar_All.pipe_left mk _154_384))
end else begin
tm
end)
end))
end
| FStar_Parser_AST.Construct (l, args) -> begin
(

let _63_1030 = (match ((FStar_Parser_Env.try_lookup_datacon env l)) with
| None -> begin
(let _154_386 = (let _154_385 = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_lid env) l)
in (FStar_All.pipe_left Prims.fst _154_385))
in (_154_386, false))
end
| Some (head) -> begin
(let _154_387 = (mk (FStar_Syntax_Syntax.Tm_fvar (head)))
in (_154_387, true))
end)
in (match (_63_1030) with
| (head, is_data) -> begin
(match (args) with
| [] -> begin
head
end
| _63_1033 -> begin
(

let args = (FStar_List.map (fun _63_1036 -> (match (_63_1036) with
| (t, imp) -> begin
(

let te = (desugar_term env t)
in (arg_withimp_e imp te))
end)) args)
in (

let app = (mk (FStar_Syntax_Syntax.Tm_app ((head, args))))
in if is_data then begin
(mk (FStar_Syntax_Syntax.Tm_meta ((app, FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Data_app)))))
end else begin
app
end))
end)
end))
end
| FStar_Parser_AST.Sum (binders, t) -> begin
(

let _63_1064 = (FStar_List.fold_left (fun _63_1047 b -> (match (_63_1047) with
| (env, tparams, typs) -> begin
(

let _63_1051 = (desugar_binder env b)
in (match (_63_1051) with
| (xopt, t) -> begin
(

let _63_1057 = (match (xopt) with
| None -> begin
(let _154_391 = (FStar_Syntax_Syntax.new_bv (Some (top.FStar_Parser_AST.range)) FStar_Syntax_Syntax.tun)
in (env, _154_391))
end
| Some (x) -> begin
(FStar_Parser_Env.push_bv env x)
end)
in (match (_63_1057) with
| (env, x) -> begin
(let _154_395 = (let _154_394 = (let _154_393 = (let _154_392 = (no_annot_abs tparams t)
in (FStar_All.pipe_left FStar_Syntax_Syntax.as_arg _154_392))
in (_154_393)::[])
in (FStar_List.append typs _154_394))
in (env, (FStar_List.append tparams ((((

let _63_1058 = x
in {FStar_Syntax_Syntax.ppname = _63_1058.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = _63_1058.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = t}), None))::[])), _154_395))
end))
end))
end)) (env, [], []) (FStar_List.append binders (((FStar_Parser_AST.mk_binder (FStar_Parser_AST.NoName (t)) t.FStar_Parser_AST.range FStar_Parser_AST.Type None))::[])))
in (match (_63_1064) with
| (env, _63_1062, targs) -> begin
(

let _63_1068 = (let _154_396 = (FStar_Syntax_Util.mk_dtuple_lid (FStar_List.length targs) top.FStar_Parser_AST.range)
in (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_lid env) _154_396))
in (match (_63_1068) with
| (tup, _63_1067) -> begin
(FStar_All.pipe_left mk (FStar_Syntax_Syntax.Tm_app ((tup, targs))))
end))
end))
end
| FStar_Parser_AST.Product (binders, t) -> begin
(

let _63_1075 = (uncurry binders t)
in (match (_63_1075) with
| (bs, t) -> begin
(

let rec aux = (fun env bs _63_8 -> (match (_63_8) with
| [] -> begin
(

let cod = (desugar_comp top.FStar_Parser_AST.range true env t)
in (let _154_403 = (FStar_Syntax_Util.arrow (FStar_List.rev bs) cod)
in (FStar_All.pipe_left setpos _154_403)))
end
| (hd)::tl -> begin
(

let mlenv = (FStar_Parser_Env.default_ml env)
in (

let bb = (desugar_binder mlenv hd)
in (

let _63_1089 = (as_binder env hd.FStar_Parser_AST.aqual bb)
in (match (_63_1089) with
| (b, env) -> begin
(aux env ((b)::bs) tl)
end))))
end))
in (aux env [] bs))
end))
end
| FStar_Parser_AST.Refine (b, f) -> begin
(match ((desugar_binder env b)) with
| (None, _63_1096) -> begin
(FStar_All.failwith "Missing binder in refinement")
end
| b -> begin
(

let _63_1104 = (as_binder env None b)
in (match (_63_1104) with
| ((x, _63_1101), env) -> begin
(

let f = (desugar_formula env f)
in (let _154_404 = (FStar_Syntax_Util.refine x f)
in (FStar_All.pipe_left setpos _154_404)))
end))
end)
end
| FStar_Parser_AST.Abs (binders, body) -> begin
(

let _63_1124 = (FStar_List.fold_left (fun _63_1112 pat -> (match (_63_1112) with
| (env, ftvs) -> begin
(match (pat.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatAscribed (_63_1115, t) -> begin
(let _154_408 = (let _154_407 = (free_type_vars env t)
in (FStar_List.append _154_407 ftvs))
in (env, _154_408))
end
| _63_1120 -> begin
(env, ftvs)
end)
end)) (env, []) binders)
in (match (_63_1124) with
| (_63_1122, ftv) -> begin
(

let ftv = (sort_ftv ftv)
in (

let binders = (let _154_410 = (FStar_All.pipe_right ftv (FStar_List.map (fun a -> (FStar_Parser_AST.mk_pattern (FStar_Parser_AST.PatTvar ((a, Some (FStar_Parser_AST.Implicit)))) top.FStar_Parser_AST.range))))
in (FStar_List.append _154_410 binders))
in (

let rec aux = (fun env bs sc_pat_opt _63_9 -> (match (_63_9) with
| [] -> begin
(

let body = (desugar_term env body)
in (

let body = (match (sc_pat_opt) with
| Some (sc, pat) -> begin
(

let body = (let _154_420 = (let _154_419 = (FStar_Syntax_Syntax.pat_bvs pat)
in (FStar_All.pipe_right _154_419 (FStar_List.map FStar_Syntax_Syntax.mk_binder)))
in (FStar_Syntax_Subst.close _154_420 body))
in (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_match ((sc, ((pat, None, body))::[]))) None body.FStar_Syntax_Syntax.pos))
end
| None -> begin
body
end)
in (let _154_421 = (no_annot_abs (FStar_List.rev bs) body)
in (setpos _154_421))))
end
| (p)::rest -> begin
(

let _63_1148 = (desugar_binding_pat env p)
in (match (_63_1148) with
| (env, b, pat) -> begin
(

let _63_1199 = (match (b) with
| LetBinder (_63_1150) -> begin
(FStar_All.failwith "Impossible")
end
| LocalBinder (x, aq) -> begin
(

let sc_pat_opt = (match ((pat, sc_pat_opt)) with
| (None, _63_1158) -> begin
sc_pat_opt
end
| (Some (p), None) -> begin
(let _154_423 = (let _154_422 = (FStar_Syntax_Syntax.bv_to_name x)
in (_154_422, p))
in Some (_154_423))
end
| (Some (p), Some (sc, p')) -> begin
(match ((sc.FStar_Syntax_Syntax.n, p'.FStar_Syntax_Syntax.v)) with
| (FStar_Syntax_Syntax.Tm_name (_63_1172), _63_1175) -> begin
(

let tup2 = (let _154_424 = (FStar_Syntax_Util.mk_tuple_data_lid 2 top.FStar_Parser_AST.range)
in (FStar_Syntax_Syntax.lid_as_fv _154_424 FStar_Syntax_Syntax.Delta_constant (Some (FStar_Syntax_Syntax.Data_ctor))))
in (

let sc = (let _154_432 = (let _154_431 = (let _154_430 = (mk (FStar_Syntax_Syntax.Tm_fvar (tup2)))
in (let _154_429 = (let _154_428 = (FStar_Syntax_Syntax.as_arg sc)
in (let _154_427 = (let _154_426 = (let _154_425 = (FStar_Syntax_Syntax.bv_to_name x)
in (FStar_All.pipe_left FStar_Syntax_Syntax.as_arg _154_425))
in (_154_426)::[])
in (_154_428)::_154_427))
in (_154_430, _154_429)))
in FStar_Syntax_Syntax.Tm_app (_154_431))
in (FStar_Syntax_Syntax.mk _154_432 None top.FStar_Parser_AST.range))
in (

let p = (let _154_433 = (FStar_Range.union_ranges p'.FStar_Syntax_Syntax.p p.FStar_Syntax_Syntax.p)
in (FStar_Syntax_Syntax.withinfo (FStar_Syntax_Syntax.Pat_cons ((tup2, ((p', false))::((p, false))::[]))) FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n _154_433))
in Some ((sc, p)))))
end
| (FStar_Syntax_Syntax.Tm_app (_63_1181, args), FStar_Syntax_Syntax.Pat_cons (_63_1186, pats)) -> begin
(

let tupn = (let _154_434 = (FStar_Syntax_Util.mk_tuple_data_lid (1 + (FStar_List.length args)) top.FStar_Parser_AST.range)
in (FStar_Syntax_Syntax.lid_as_fv _154_434 FStar_Syntax_Syntax.Delta_constant (Some (FStar_Syntax_Syntax.Data_ctor))))
in (

let sc = (let _154_441 = (let _154_440 = (let _154_439 = (mk (FStar_Syntax_Syntax.Tm_fvar (tupn)))
in (let _154_438 = (let _154_437 = (let _154_436 = (let _154_435 = (FStar_Syntax_Syntax.bv_to_name x)
in (FStar_All.pipe_left FStar_Syntax_Syntax.as_arg _154_435))
in (_154_436)::[])
in (FStar_List.append args _154_437))
in (_154_439, _154_438)))
in FStar_Syntax_Syntax.Tm_app (_154_440))
in (mk _154_441))
in (

let p = (let _154_442 = (FStar_Range.union_ranges p'.FStar_Syntax_Syntax.p p.FStar_Syntax_Syntax.p)
in (FStar_Syntax_Syntax.withinfo (FStar_Syntax_Syntax.Pat_cons ((tupn, (FStar_List.append pats (((p, false))::[]))))) FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n _154_442))
in Some ((sc, p)))))
end
| _63_1195 -> begin
(FStar_All.failwith "Impossible")
end)
end)
in ((x, aq), sc_pat_opt))
end)
in (match (_63_1199) with
| (b, sc_pat_opt) -> begin
(aux env ((b)::bs) sc_pat_opt rest)
end))
end))
end))
in (aux env [] None binders))))
end))
end
| FStar_Parser_AST.App ({FStar_Parser_AST.tm = FStar_Parser_AST.Var (a); FStar_Parser_AST.range = _63_1203; FStar_Parser_AST.level = _63_1201}, phi, _63_1209) when ((FStar_Ident.lid_equals a FStar_Syntax_Const.assert_lid) || (FStar_Ident.lid_equals a FStar_Syntax_Const.assume_lid)) -> begin
(

let phi = (desugar_formula env phi)
in (let _154_450 = (let _154_449 = (let _154_448 = (FStar_Syntax_Syntax.fvar a FStar_Syntax_Syntax.Delta_equational None)
in (let _154_447 = (let _154_446 = (FStar_Syntax_Syntax.as_arg phi)
in (let _154_445 = (let _154_444 = (let _154_443 = (mk (FStar_Syntax_Syntax.Tm_constant (FStar_Const.Const_unit)))
in (FStar_All.pipe_left FStar_Syntax_Syntax.as_arg _154_443))
in (_154_444)::[])
in (_154_446)::_154_445))
in (_154_448, _154_447)))
in FStar_Syntax_Syntax.Tm_app (_154_449))
in (mk _154_450)))
end
| FStar_Parser_AST.App (_63_1214) -> begin
(

let rec aux = (fun args e -> (match ((let _154_455 = (unparen e)
in _154_455.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.App (e, t, imp) -> begin
(

let arg = (let _154_456 = (desugar_term env t)
in (FStar_All.pipe_left (arg_withimp_e imp) _154_456))
in (aux ((arg)::args) e))
end
| _63_1226 -> begin
(

let head = (desugar_term env e)
in (mk (FStar_Syntax_Syntax.Tm_app ((head, args)))))
end))
in (aux [] top))
end
| FStar_Parser_AST.Seq (t1, t2) -> begin
(let _154_459 = (let _154_458 = (let _154_457 = (desugar_term env (FStar_Parser_AST.mk_term (FStar_Parser_AST.Let ((FStar_Parser_AST.NoLetQualifier, (((FStar_Parser_AST.mk_pattern FStar_Parser_AST.PatWild t1.FStar_Parser_AST.range), t1))::[], t2))) top.FStar_Parser_AST.range FStar_Parser_AST.Expr))
in (_154_457, FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Sequence)))
in FStar_Syntax_Syntax.Tm_meta (_154_458))
in (mk _154_459))
end
| FStar_Parser_AST.Let (qual, ((pat, _snd))::_tl, body) -> begin
(

let is_rec = (qual = FStar_Parser_AST.Rec)
in (

let ds_let_rec_or_app = (fun _63_1243 -> (match (()) with
| () -> begin
(

let bindings = ((pat, _snd))::_tl
in (

let funs = (FStar_All.pipe_right bindings (FStar_List.map (fun _63_1247 -> (match (_63_1247) with
| (p, def) -> begin
if (is_app_pattern p) then begin
(let _154_463 = (destruct_app_pattern env top_level p)
in (_154_463, def))
end else begin
(match ((FStar_Parser_AST.un_function p def)) with
| Some (p, def) -> begin
(let _154_464 = (destruct_app_pattern env top_level p)
in (_154_464, def))
end
| _63_1253 -> begin
(match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatAscribed ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (id, _63_1258); FStar_Parser_AST.prange = _63_1255}, t) -> begin
if top_level then begin
(let _154_467 = (let _154_466 = (let _154_465 = (FStar_Parser_Env.qualify env id)
in FStar_Util.Inr (_154_465))
in (_154_466, [], Some (t)))
in (_154_467, def))
end else begin
((FStar_Util.Inl (id), [], Some (t)), def)
end
end
| FStar_Parser_AST.PatVar (id, _63_1267) -> begin
if top_level then begin
(let _154_470 = (let _154_469 = (let _154_468 = (FStar_Parser_Env.qualify env id)
in FStar_Util.Inr (_154_468))
in (_154_469, [], None))
in (_154_470, def))
end else begin
((FStar_Util.Inl (id), [], None), def)
end
end
| _63_1271 -> begin
(Prims.raise (FStar_Syntax_Syntax.Error (("Unexpected let binding", p.FStar_Parser_AST.prange))))
end)
end)
end
end))))
in (

let _63_1300 = (FStar_List.fold_left (fun _63_1276 _63_1285 -> (match ((_63_1276, _63_1285)) with
| ((env, fnames, rec_bindings), ((f, _63_1279, _63_1281), _63_1284)) -> begin
(

let _63_1296 = (match (f) with
| FStar_Util.Inl (x) -> begin
(

let _63_1290 = (FStar_Parser_Env.push_bv env x)
in (match (_63_1290) with
| (env, xx) -> begin
(let _154_474 = (let _154_473 = (FStar_Syntax_Syntax.mk_binder xx)
in (_154_473)::rec_bindings)
in (env, FStar_Util.Inl (xx), _154_474))
end))
end
| FStar_Util.Inr (l) -> begin
(let _154_475 = (FStar_Parser_Env.push_top_level_rec_binding env l.FStar_Ident.ident FStar_Syntax_Syntax.Delta_equational)
in (_154_475, FStar_Util.Inr (l), rec_bindings))
end)
in (match (_63_1296) with
| (env, lbname, rec_bindings) -> begin
(env, (lbname)::fnames, rec_bindings)
end))
end)) (env, [], []) funs)
in (match (_63_1300) with
| (env', fnames, rec_bindings) -> begin
(

let fnames = (FStar_List.rev fnames)
in (

let desugar_one_def = (fun env lbname _63_1311 -> (match (_63_1311) with
| ((_63_1306, args, result_t), def) -> begin
(

let def = (match (result_t) with
| None -> begin
def
end
| Some (t) -> begin
(let _154_482 = (FStar_Range.union_ranges t.FStar_Parser_AST.range def.FStar_Parser_AST.range)
in (FStar_Parser_AST.mk_term (FStar_Parser_AST.Ascribed ((def, t))) _154_482 FStar_Parser_AST.Expr))
end)
in (

let def = (match (args) with
| [] -> begin
def
end
| _63_1318 -> begin
(FStar_Parser_AST.mk_term (FStar_Parser_AST.un_curry_abs args def) top.FStar_Parser_AST.range top.FStar_Parser_AST.level)
end)
in (

let body = (desugar_term env def)
in (

let lbname = (match (lbname) with
| FStar_Util.Inl (x) -> begin
FStar_Util.Inl (x)
end
| FStar_Util.Inr (l) -> begin
(let _154_484 = (let _154_483 = (incr_delta_qualifier body)
in (FStar_Syntax_Syntax.lid_as_fv l _154_483 None))
in FStar_Util.Inr (_154_484))
end)
in (

let body = if is_rec then begin
(FStar_Syntax_Subst.close rec_bindings body)
end else begin
body
end
in (mk_lb (lbname, FStar_Syntax_Syntax.tun, body)))))))
end))
in (

let lbs = (FStar_List.map2 (desugar_one_def (if is_rec then begin
env'
end else begin
env
end)) fnames funs)
in (

let body = (desugar_term env' body)
in (let _154_487 = (let _154_486 = (let _154_485 = (FStar_Syntax_Subst.close rec_bindings body)
in ((is_rec, lbs), _154_485))
in FStar_Syntax_Syntax.Tm_let (_154_486))
in (FStar_All.pipe_left mk _154_487))))))
end))))
end))
in (

let ds_non_rec = (fun pat t1 t2 -> (

let t1 = (desugar_term env t1)
in (

let is_mutable = (qual = FStar_Parser_AST.Mutable)
in (

let t1 = if is_mutable then begin
(mk_ref_alloc t1)
end else begin
t1
end
in (

let _63_1339 = (desugar_binding_pat_maybe_top top_level env pat is_mutable)
in (match (_63_1339) with
| (env, binder, pat) -> begin
(

let tm = (match (binder) with
| LetBinder (l, t) -> begin
(

let body = (desugar_term env t2)
in (

let fv = (let _154_494 = (incr_delta_qualifier t1)
in (FStar_Syntax_Syntax.lid_as_fv l _154_494 None))
in (FStar_All.pipe_left mk (FStar_Syntax_Syntax.Tm_let (((false, ({FStar_Syntax_Syntax.lbname = FStar_Util.Inr (fv); FStar_Syntax_Syntax.lbunivs = []; FStar_Syntax_Syntax.lbtyp = t; FStar_Syntax_Syntax.lbeff = FStar_Syntax_Const.effect_ALL_lid; FStar_Syntax_Syntax.lbdef = t1})::[]), body))))))
end
| LocalBinder (x, _63_1348) -> begin
(

let body = (desugar_term env t2)
in (

let body = (match (pat) with
| (None) | (Some ({FStar_Syntax_Syntax.v = FStar_Syntax_Syntax.Pat_wild (_); FStar_Syntax_Syntax.ty = _; FStar_Syntax_Syntax.p = _})) -> begin
body
end
| Some (pat) -> begin
(let _154_499 = (let _154_498 = (let _154_497 = (FStar_Syntax_Syntax.bv_to_name x)
in (let _154_496 = (let _154_495 = (FStar_Syntax_Util.branch (pat, None, body))
in (_154_495)::[])
in (_154_497, _154_496)))
in FStar_Syntax_Syntax.Tm_match (_154_498))
in (FStar_Syntax_Syntax.mk _154_499 None body.FStar_Syntax_Syntax.pos))
end)
in (let _154_504 = (let _154_503 = (let _154_502 = (let _154_501 = (let _154_500 = (FStar_Syntax_Syntax.mk_binder x)
in (_154_500)::[])
in (FStar_Syntax_Subst.close _154_501 body))
in ((false, ((mk_lb (FStar_Util.Inl (x), x.FStar_Syntax_Syntax.sort, t1)))::[]), _154_502))
in FStar_Syntax_Syntax.Tm_let (_154_503))
in (FStar_All.pipe_left mk _154_504))))
end)
in if is_mutable then begin
(FStar_All.pipe_left mk (FStar_Syntax_Syntax.Tm_meta ((tm, FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Mutable_alloc)))))
end else begin
tm
end)
end))))))
in if (is_rec || (is_app_pattern pat)) then begin
(ds_let_rec_or_app ())
end else begin
(ds_non_rec pat _snd body)
end)))
end
| FStar_Parser_AST.If (t1, t2, t3) -> begin
(

let x = (FStar_Syntax_Syntax.new_bv (Some (t3.FStar_Parser_AST.range)) FStar_Syntax_Syntax.tun)
in (let _154_515 = (let _154_514 = (let _154_513 = (desugar_term env t1)
in (let _154_512 = (let _154_511 = (let _154_506 = (FStar_Syntax_Syntax.withinfo (FStar_Syntax_Syntax.Pat_constant (FStar_Const.Const_bool (true))) FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n t2.FStar_Parser_AST.range)
in (let _154_505 = (desugar_term env t2)
in (_154_506, None, _154_505)))
in (let _154_510 = (let _154_509 = (let _154_508 = (FStar_Syntax_Syntax.withinfo (FStar_Syntax_Syntax.Pat_wild (x)) FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n t3.FStar_Parser_AST.range)
in (let _154_507 = (desugar_term env t3)
in (_154_508, None, _154_507)))
in (_154_509)::[])
in (_154_511)::_154_510))
in (_154_513, _154_512)))
in FStar_Syntax_Syntax.Tm_match (_154_514))
in (mk _154_515)))
end
| FStar_Parser_AST.TryWith (e, branches) -> begin
(

let r = top.FStar_Parser_AST.range
in (

let handler = (FStar_Parser_AST.mk_function branches r r)
in (

let body = (FStar_Parser_AST.mk_function ((((FStar_Parser_AST.mk_pattern (FStar_Parser_AST.PatConst (FStar_Const.Const_unit)) r), None, e))::[]) r r)
in (

let a1 = (FStar_Parser_AST.mk_term (FStar_Parser_AST.App (((FStar_Parser_AST.mk_term (FStar_Parser_AST.Var (FStar_Syntax_Const.try_with_lid)) r top.FStar_Parser_AST.level), body, FStar_Parser_AST.Nothing))) r top.FStar_Parser_AST.level)
in (

let a2 = (FStar_Parser_AST.mk_term (FStar_Parser_AST.App ((a1, handler, FStar_Parser_AST.Nothing))) r top.FStar_Parser_AST.level)
in (desugar_term env a2))))))
end
| FStar_Parser_AST.Match (e, branches) -> begin
(

let desugar_branch = (fun _63_1389 -> (match (_63_1389) with
| (pat, wopt, b) -> begin
(

let _63_1392 = (desugar_match_pat env pat)
in (match (_63_1392) with
| (env, pat) -> begin
(

let wopt = (match (wopt) with
| None -> begin
None
end
| Some (e) -> begin
(let _154_518 = (desugar_term env e)
in Some (_154_518))
end)
in (

let b = (desugar_term env b)
in (FStar_Syntax_Util.branch (pat, wopt, b))))
end))
end))
in (let _154_522 = (let _154_521 = (let _154_520 = (desugar_term env e)
in (let _154_519 = (FStar_List.map desugar_branch branches)
in (_154_520, _154_519)))
in FStar_Syntax_Syntax.Tm_match (_154_521))
in (FStar_All.pipe_left mk _154_522)))
end
| FStar_Parser_AST.Ascribed (e, t) -> begin
(

let env = (FStar_Parser_Env.default_ml env)
in (

let c = (desugar_comp t.FStar_Parser_AST.range true env t)
in (

let annot = if (FStar_Syntax_Util.is_ml_comp c) then begin
FStar_Util.Inl ((FStar_Syntax_Util.comp_result c))
end else begin
FStar_Util.Inr (c)
end
in (let _154_525 = (let _154_524 = (let _154_523 = (desugar_term env e)
in (_154_523, annot, None))
in FStar_Syntax_Syntax.Tm_ascribed (_154_524))
in (FStar_All.pipe_left mk _154_525)))))
end
| FStar_Parser_AST.Record (_63_1406, []) -> begin
(Prims.raise (FStar_Syntax_Syntax.Error (("Unexpected empty record", top.FStar_Parser_AST.range))))
end
| FStar_Parser_AST.Record (eopt, fields) -> begin
(

let _63_1417 = (FStar_List.hd fields)
in (match (_63_1417) with
| (f, _63_1416) -> begin
(

let qfn = (fun g -> (FStar_Ident.lid_of_ids (FStar_List.append f.FStar_Ident.ns ((g)::[]))))
in (

let _63_1423 = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_record_by_field_name env) f)
in (match (_63_1423) with
| (record, _63_1422) -> begin
(

let get_field = (fun xopt f -> (

let fn = f.FStar_Ident.ident
in (

let found = (FStar_All.pipe_right fields (FStar_Util.find_opt (fun _63_1431 -> (match (_63_1431) with
| (g, _63_1430) -> begin
(

let gn = g.FStar_Ident.ident
in (fn.FStar_Ident.idText = gn.FStar_Ident.idText))
end))))
in (match (found) with
| Some (_63_1435, e) -> begin
(let _154_533 = (qfn fn)
in (_154_533, e))
end
| None -> begin
(match (xopt) with
| None -> begin
(let _154_536 = (let _154_535 = (let _154_534 = (FStar_Util.format1 "Field %s is missing" (FStar_Ident.text_of_lid f))
in (_154_534, top.FStar_Parser_AST.range))
in FStar_Syntax_Syntax.Error (_154_535))
in (Prims.raise _154_536))
end
| Some (x) -> begin
(let _154_537 = (qfn fn)
in (_154_537, (FStar_Parser_AST.mk_term (FStar_Parser_AST.Project ((x, f))) x.FStar_Parser_AST.range x.FStar_Parser_AST.level)))
end)
end))))
in (

let recterm = (match (eopt) with
| None -> begin
(let _154_542 = (let _154_541 = (FStar_All.pipe_right record.FStar_Parser_Env.fields (FStar_List.map (fun _63_1447 -> (match (_63_1447) with
| (f, _63_1446) -> begin
(let _154_540 = (let _154_539 = (get_field None f)
in (FStar_All.pipe_left Prims.snd _154_539))
in (_154_540, FStar_Parser_AST.Nothing))
end))))
in (record.FStar_Parser_Env.constrname, _154_541))
in FStar_Parser_AST.Construct (_154_542))
end
| Some (e) -> begin
(

let x = (FStar_Ident.gen e.FStar_Parser_AST.range)
in (

let xterm = (let _154_544 = (let _154_543 = (FStar_Ident.lid_of_ids ((x)::[]))
in FStar_Parser_AST.Var (_154_543))
in (FStar_Parser_AST.mk_term _154_544 x.FStar_Ident.idRange FStar_Parser_AST.Expr))
in (

let record = (let _154_547 = (let _154_546 = (FStar_All.pipe_right record.FStar_Parser_Env.fields (FStar_List.map (fun _63_1455 -> (match (_63_1455) with
| (f, _63_1454) -> begin
(get_field (Some (xterm)) f)
end))))
in (None, _154_546))
in FStar_Parser_AST.Record (_154_547))
in FStar_Parser_AST.Let ((FStar_Parser_AST.NoLetQualifier, (((FStar_Parser_AST.mk_pattern (FStar_Parser_AST.PatVar ((x, None))) x.FStar_Ident.idRange), e))::[], (FStar_Parser_AST.mk_term record top.FStar_Parser_AST.range top.FStar_Parser_AST.level))))))
end)
in (

let recterm = (FStar_Parser_AST.mk_term recterm top.FStar_Parser_AST.range top.FStar_Parser_AST.level)
in (

let e = (desugar_term env recterm)
in (match (e.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_meta ({FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_app ({FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar (fv); FStar_Syntax_Syntax.tk = _63_1471; FStar_Syntax_Syntax.pos = _63_1469; FStar_Syntax_Syntax.vars = _63_1467}, args); FStar_Syntax_Syntax.tk = _63_1465; FStar_Syntax_Syntax.pos = _63_1463; FStar_Syntax_Syntax.vars = _63_1461}, FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Data_app)) -> begin
(

let e = (let _154_555 = (let _154_554 = (let _154_553 = (let _154_552 = (FStar_Ident.set_lid_range fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v e.FStar_Syntax_Syntax.pos)
in (let _154_551 = (let _154_550 = (let _154_549 = (let _154_548 = (FStar_All.pipe_right record.FStar_Parser_Env.fields (FStar_List.map Prims.fst))
in (record.FStar_Parser_Env.typename, _154_548))
in FStar_Syntax_Syntax.Record_ctor (_154_549))
in Some (_154_550))
in (FStar_Syntax_Syntax.fvar _154_552 FStar_Syntax_Syntax.Delta_constant _154_551)))
in (_154_553, args))
in FStar_Syntax_Syntax.Tm_app (_154_554))
in (FStar_All.pipe_left mk _154_555))
in (FStar_All.pipe_left mk (FStar_Syntax_Syntax.Tm_meta ((e, FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Data_app))))))
end
| _63_1485 -> begin
e
end)))))
end)))
end))
end
| FStar_Parser_AST.Project (e, f) -> begin
(

let _63_1492 = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_projector_by_field_name env) f)
in (match (_63_1492) with
| (fieldname, is_rec) -> begin
(

let e = (desugar_term env e)
in (

let fn = (

let _63_1497 = (FStar_Util.prefix fieldname.FStar_Ident.ns)
in (match (_63_1497) with
| (ns, _63_1496) -> begin
(FStar_Ident.lid_of_ids (FStar_List.append ns ((f.FStar_Ident.ident)::[])))
end))
in (

let qual = if is_rec then begin
Some (FStar_Syntax_Syntax.Record_projector (fn))
end else begin
None
end
in (let _154_561 = (let _154_560 = (let _154_559 = (let _154_556 = (FStar_Ident.set_lid_range fieldname (FStar_Ident.range_of_lid f))
in (FStar_Syntax_Syntax.fvar _154_556 FStar_Syntax_Syntax.Delta_equational qual))
in (let _154_558 = (let _154_557 = (FStar_Syntax_Syntax.as_arg e)
in (_154_557)::[])
in (_154_559, _154_558)))
in FStar_Syntax_Syntax.Tm_app (_154_560))
in (FStar_All.pipe_left mk _154_561)))))
end))
end
| (FStar_Parser_AST.NamedTyp (_, e)) | (FStar_Parser_AST.Paren (e)) -> begin
(desugar_term env e)
end
| _63_1507 when (top.FStar_Parser_AST.level = FStar_Parser_AST.Formula) -> begin
(desugar_formula env top)
end
| _63_1509 -> begin
(FStar_Parser_AST.error "Unexpected term" top top.FStar_Parser_AST.range)
end))))
and desugar_args : FStar_Parser_Env.env  ->  (FStar_Parser_AST.term * FStar_Parser_AST.imp) Prims.list  ->  (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list = (fun env args -> (FStar_All.pipe_right args (FStar_List.map (fun _63_1514 -> (match (_63_1514) with
| (a, imp) -> begin
(let _154_565 = (desugar_term env a)
in (arg_withimp_e imp _154_565))
end)))))
and desugar_comp : FStar_Range.range  ->  Prims.bool  ->  FStar_Parser_Env.env  ->  FStar_Parser_AST.term  ->  (FStar_Syntax_Syntax.comp', Prims.unit) FStar_Syntax_Syntax.syntax = (fun r default_ok env t -> (

let fail = (fun msg -> (Prims.raise (FStar_Syntax_Syntax.Error ((msg, r)))))
in (

let is_requires = (fun _63_1526 -> (match (_63_1526) with
| (t, _63_1525) -> begin
(match ((let _154_573 = (unparen t)
in _154_573.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Requires (_63_1528) -> begin
true
end
| _63_1531 -> begin
false
end)
end))
in (

let is_ensures = (fun _63_1536 -> (match (_63_1536) with
| (t, _63_1535) -> begin
(match ((let _154_576 = (unparen t)
in _154_576.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Ensures (_63_1538) -> begin
true
end
| _63_1541 -> begin
false
end)
end))
in (

let is_app = (fun head _63_1547 -> (match (_63_1547) with
| (t, _63_1546) -> begin
(match ((let _154_581 = (unparen t)
in _154_581.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.App ({FStar_Parser_AST.tm = FStar_Parser_AST.Var (d); FStar_Parser_AST.range = _63_1551; FStar_Parser_AST.level = _63_1549}, _63_1556, _63_1558) -> begin
(d.FStar_Ident.ident.FStar_Ident.idText = head)
end
| _63_1562 -> begin
false
end)
end))
in (

let is_decreases = (is_app "decreases")
in (

let pre_process_comp_typ = (fun t -> (

let _63_1568 = (head_and_args t)
in (match (_63_1568) with
| (head, args) -> begin
(match (head.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Name (lemma) when (lemma.FStar_Ident.ident.FStar_Ident.idText = "Lemma") -> begin
(

let unit_tm = ((FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Syntax_Const.unit_lid)) t.FStar_Parser_AST.range FStar_Parser_AST.Type), FStar_Parser_AST.Nothing)
in (

let nil_pat = ((FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Syntax_Const.nil_lid)) t.FStar_Parser_AST.range FStar_Parser_AST.Expr), FStar_Parser_AST.Nothing)
in (

let req_true = ((FStar_Parser_AST.mk_term (FStar_Parser_AST.Requires (((FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Syntax_Const.true_lid)) t.FStar_Parser_AST.range FStar_Parser_AST.Formula), None))) t.FStar_Parser_AST.range FStar_Parser_AST.Type), FStar_Parser_AST.Nothing)
in (

let args = (match (args) with
| [] -> begin
(Prims.raise (FStar_Syntax_Syntax.Error (("Not enough arguments to \'Lemma\'", t.FStar_Parser_AST.range))))
end
| (ens)::[] -> begin
(unit_tm)::(req_true)::(ens)::(nil_pat)::[]
end
| (req)::(ens)::[] when ((is_requires req) && (is_ensures ens)) -> begin
(unit_tm)::(req)::(ens)::(nil_pat)::[]
end
| (ens)::(dec)::[] when ((is_ensures ens) && (is_decreases dec)) -> begin
(unit_tm)::(req_true)::(ens)::(nil_pat)::(dec)::[]
end
| (req)::(ens)::(dec)::[] when (((is_requires req) && (is_ensures ens)) && (is_app "decreases" dec)) -> begin
(unit_tm)::(req)::(ens)::(nil_pat)::(dec)::[]
end
| more -> begin
(unit_tm)::more
end)
in (

let head = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_effect_name env) lemma)
in (head, args))))))
end
| FStar_Parser_AST.Name (l) when (FStar_Parser_Env.is_effect_name env l) -> begin
(let _154_585 = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_effect_name env) l)
in (_154_585, args))
end
| FStar_Parser_AST.Name (l) when ((let _154_586 = (FStar_Parser_Env.current_module env)
in (FStar_Ident.lid_equals _154_586 FStar_Syntax_Const.prims_lid)) && (l.FStar_Ident.ident.FStar_Ident.idText = "Tot")) -> begin
(let _154_587 = (FStar_Ident.set_lid_range FStar_Syntax_Const.effect_Tot_lid head.FStar_Parser_AST.range)
in (_154_587, args))
end
| FStar_Parser_AST.Name (l) when ((let _154_588 = (FStar_Parser_Env.current_module env)
in (FStar_Ident.lid_equals _154_588 FStar_Syntax_Const.prims_lid)) && (l.FStar_Ident.ident.FStar_Ident.idText = "GTot")) -> begin
(let _154_589 = (FStar_Ident.set_lid_range FStar_Syntax_Const.effect_GTot_lid head.FStar_Parser_AST.range)
in (_154_589, args))
end
| FStar_Parser_AST.Name (l) when ((((l.FStar_Ident.ident.FStar_Ident.idText = "Type") || (l.FStar_Ident.ident.FStar_Ident.idText = "Type0")) || (l.FStar_Ident.ident.FStar_Ident.idText = "Effect")) && default_ok) -> begin
(let _154_590 = (FStar_Ident.set_lid_range FStar_Syntax_Const.effect_Tot_lid head.FStar_Parser_AST.range)
in (_154_590, ((t, FStar_Parser_AST.Nothing))::[]))
end
| _63_1599 when default_ok -> begin
(let _154_591 = (FStar_Ident.set_lid_range env.FStar_Parser_Env.default_result_effect head.FStar_Parser_AST.range)
in (_154_591, ((t, FStar_Parser_AST.Nothing))::[]))
end
| _63_1601 -> begin
(let _154_593 = (let _154_592 = (FStar_Parser_AST.term_to_string t)
in (FStar_Util.format1 "%s is not an effect" _154_592))
in (fail _154_593))
end)
end)))
in (

let _63_1604 = (pre_process_comp_typ t)
in (match (_63_1604) with
| (eff, args) -> begin
(

let _63_1605 = if ((FStar_List.length args) = 0) then begin
(let _154_595 = (let _154_594 = (FStar_Syntax_Print.lid_to_string eff)
in (FStar_Util.format1 "Not enough args to effect %s" _154_594))
in (fail _154_595))
end else begin
()
end
in (

let _63_1609 = (let _154_597 = (FStar_List.hd args)
in (let _154_596 = (FStar_List.tl args)
in (_154_597, _154_596)))
in (match (_63_1609) with
| (result_arg, rest) -> begin
(

let result_typ = (desugar_typ env (Prims.fst result_arg))
in (

let rest = (desugar_args env rest)
in (

let _63_1634 = (FStar_All.pipe_right rest (FStar_List.partition (fun _63_1615 -> (match (_63_1615) with
| (t, _63_1614) -> begin
(match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_app ({FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar (fv); FStar_Syntax_Syntax.tk = _63_1621; FStar_Syntax_Syntax.pos = _63_1619; FStar_Syntax_Syntax.vars = _63_1617}, (_63_1626)::[]) -> begin
(FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.decreases_lid)
end
| _63_1631 -> begin
false
end)
end))))
in (match (_63_1634) with
| (dec, rest) -> begin
(

let decreases_clause = (FStar_All.pipe_right dec (FStar_List.map (fun _63_1638 -> (match (_63_1638) with
| (t, _63_1637) -> begin
(match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_app (_63_1640, ((arg, _63_1643))::[]) -> begin
FStar_Syntax_Syntax.DECREASES (arg)
end
| _63_1649 -> begin
(FStar_All.failwith "impos")
end)
end))))
in (

let no_additional_args = (((FStar_List.length decreases_clause) = 0) && ((FStar_List.length rest) = 0))
in if (no_additional_args && (FStar_Ident.lid_equals eff FStar_Syntax_Const.effect_Tot_lid)) then begin
(FStar_Syntax_Syntax.mk_Total result_typ)
end else begin
if (no_additional_args && (FStar_Ident.lid_equals eff FStar_Syntax_Const.effect_GTot_lid)) then begin
(FStar_Syntax_Syntax.mk_GTotal result_typ)
end else begin
(

let flags = if (FStar_Ident.lid_equals eff FStar_Syntax_Const.effect_Lemma_lid) then begin
(FStar_Syntax_Syntax.LEMMA)::[]
end else begin
if (FStar_Ident.lid_equals eff FStar_Syntax_Const.effect_Tot_lid) then begin
(FStar_Syntax_Syntax.TOTAL)::[]
end else begin
if (FStar_Ident.lid_equals eff FStar_Syntax_Const.effect_ML_lid) then begin
(FStar_Syntax_Syntax.MLEFFECT)::[]
end else begin
if (FStar_Ident.lid_equals eff FStar_Syntax_Const.effect_GTot_lid) then begin
(FStar_Syntax_Syntax.SOMETRIVIAL)::[]
end else begin
[]
end
end
end
end
in (

let rest = if (FStar_Ident.lid_equals eff FStar_Syntax_Const.effect_Lemma_lid) then begin
(match (rest) with
| (req)::(ens)::((pat, aq))::[] -> begin
(

let pat = (match (pat.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_fvar (fv) when (FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.nil_lid) -> begin
(

let nil = (FStar_Syntax_Syntax.mk_Tm_uinst pat ((FStar_Syntax_Syntax.U_succ (FStar_Syntax_Syntax.U_zero))::[]))
in (

let pattern = (let _154_601 = (let _154_600 = (FStar_Ident.set_lid_range FStar_Syntax_Const.pattern_lid pat.FStar_Syntax_Syntax.pos)
in (FStar_Syntax_Syntax.fvar _154_600 FStar_Syntax_Syntax.Delta_constant None))
in (FStar_Syntax_Syntax.mk_Tm_uinst _154_601 ((FStar_Syntax_Syntax.U_zero)::[])))
in (FStar_Syntax_Syntax.mk_Tm_app nil (((pattern, Some (FStar_Syntax_Syntax.imp_tag)))::[]) None pat.FStar_Syntax_Syntax.pos)))
end
| _63_1664 -> begin
pat
end)
in (let _154_605 = (let _154_604 = (let _154_603 = (let _154_602 = (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_meta ((pat, FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Meta_smt_pat)))) None pat.FStar_Syntax_Syntax.pos)
in (_154_602, aq))
in (_154_603)::[])
in (ens)::_154_604)
in (req)::_154_605))
end
| _63_1667 -> begin
rest
end)
end else begin
rest
end
in (FStar_Syntax_Syntax.mk_Comp {FStar_Syntax_Syntax.effect_name = eff; FStar_Syntax_Syntax.result_typ = result_typ; FStar_Syntax_Syntax.effect_args = rest; FStar_Syntax_Syntax.flags = (FStar_List.append flags decreases_clause)})))
end
end))
end))))
end)))
end)))))))))
and desugar_formula : env_t  ->  FStar_Parser_AST.term  ->  FStar_Syntax_Syntax.term = (fun env f -> (

let connective = (fun s -> (match (s) with
| "/\\" -> begin
Some (FStar_Syntax_Const.and_lid)
end
| "\\/" -> begin
Some (FStar_Syntax_Const.or_lid)
end
| "==>" -> begin
Some (FStar_Syntax_Const.imp_lid)
end
| "<==>" -> begin
Some (FStar_Syntax_Const.iff_lid)
end
| "~" -> begin
Some (FStar_Syntax_Const.not_lid)
end
| _63_1679 -> begin
None
end))
in (

let mk = (fun t -> (FStar_Syntax_Syntax.mk t None f.FStar_Parser_AST.range))
in (

let pos = (fun t -> (t None f.FStar_Parser_AST.range))
in (

let setpos = (fun t -> (

let _63_1686 = t
in {FStar_Syntax_Syntax.n = _63_1686.FStar_Syntax_Syntax.n; FStar_Syntax_Syntax.tk = _63_1686.FStar_Syntax_Syntax.tk; FStar_Syntax_Syntax.pos = f.FStar_Parser_AST.range; FStar_Syntax_Syntax.vars = _63_1686.FStar_Syntax_Syntax.vars}))
in (

let desugar_quant = (fun q b pats body -> (

let tk = (desugar_binder env (

let _63_1693 = b
in {FStar_Parser_AST.b = _63_1693.FStar_Parser_AST.b; FStar_Parser_AST.brange = _63_1693.FStar_Parser_AST.brange; FStar_Parser_AST.blevel = FStar_Parser_AST.Formula; FStar_Parser_AST.aqual = _63_1693.FStar_Parser_AST.aqual}))
in (

let desugar_pats = (fun env pats -> (FStar_List.map (fun es -> (FStar_All.pipe_right es (FStar_List.map (fun e -> (let _154_640 = (desugar_term env e)
in (FStar_All.pipe_left (arg_withimp_t FStar_Parser_AST.Nothing) _154_640)))))) pats))
in (match (tk) with
| (Some (a), k) -> begin
(

let _63_1707 = (FStar_Parser_Env.push_bv env a)
in (match (_63_1707) with
| (env, a) -> begin
(

let a = (

let _63_1708 = a
in {FStar_Syntax_Syntax.ppname = _63_1708.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = _63_1708.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = k})
in (

let pats = (desugar_pats env pats)
in (

let body = (desugar_formula env body)
in (

let body = (match (pats) with
| [] -> begin
body
end
| _63_1715 -> begin
(mk (FStar_Syntax_Syntax.Tm_meta ((body, FStar_Syntax_Syntax.Meta_pattern (pats)))))
end)
in (

let body = (let _154_643 = (let _154_642 = (let _154_641 = (FStar_Syntax_Syntax.mk_binder a)
in (_154_641)::[])
in (no_annot_abs _154_642 body))
in (FStar_All.pipe_left setpos _154_643))
in (let _154_649 = (let _154_648 = (let _154_647 = (let _154_644 = (FStar_Ident.set_lid_range q b.FStar_Parser_AST.brange)
in (FStar_Syntax_Syntax.fvar _154_644 (FStar_Syntax_Syntax.Delta_unfoldable (1)) None))
in (let _154_646 = (let _154_645 = (FStar_Syntax_Syntax.as_arg body)
in (_154_645)::[])
in (_154_647, _154_646)))
in FStar_Syntax_Syntax.Tm_app (_154_648))
in (FStar_All.pipe_left mk _154_649)))))))
end))
end
| _63_1719 -> begin
(FStar_All.failwith "impossible")
end))))
in (

let push_quant = (fun q binders pats body -> (match (binders) with
| (b)::(b')::_rest -> begin
(

let rest = (b')::_rest
in (

let body = (let _154_664 = (q (rest, pats, body))
in (let _154_663 = (FStar_Range.union_ranges b'.FStar_Parser_AST.brange body.FStar_Parser_AST.range)
in (FStar_Parser_AST.mk_term _154_664 _154_663 FStar_Parser_AST.Formula)))
in (let _154_665 = (q ((b)::[], [], body))
in (FStar_Parser_AST.mk_term _154_665 f.FStar_Parser_AST.range FStar_Parser_AST.Formula))))
end
| _63_1733 -> begin
(FStar_All.failwith "impossible")
end))
in (match ((let _154_666 = (unparen f)
in _154_666.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Labeled (f, l, p) -> begin
(

let f = (desugar_formula env f)
in (FStar_All.pipe_left mk (FStar_Syntax_Syntax.Tm_meta ((f, FStar_Syntax_Syntax.Meta_labeled ((l, f.FStar_Syntax_Syntax.pos, p)))))))
end
| (FStar_Parser_AST.QForall ([], _, _)) | (FStar_Parser_AST.QExists ([], _, _)) -> begin
(FStar_All.failwith "Impossible: Quantifier without binders")
end
| FStar_Parser_AST.QForall ((_1)::(_2)::_3, pats, body) -> begin
(

let binders = (_1)::(_2)::_3
in (let _154_668 = (push_quant (fun x -> FStar_Parser_AST.QForall (x)) binders pats body)
in (desugar_formula env _154_668)))
end
| FStar_Parser_AST.QExists ((_1)::(_2)::_3, pats, body) -> begin
(

let binders = (_1)::(_2)::_3
in (let _154_670 = (push_quant (fun x -> FStar_Parser_AST.QExists (x)) binders pats body)
in (desugar_formula env _154_670)))
end
| FStar_Parser_AST.QForall ((b)::[], pats, body) -> begin
(desugar_quant FStar_Syntax_Const.forall_lid b pats body)
end
| FStar_Parser_AST.QExists ((b)::[], pats, body) -> begin
(desugar_quant FStar_Syntax_Const.exists_lid b pats body)
end
| FStar_Parser_AST.Paren (f) -> begin
(desugar_formula env f)
end
| _63_1791 -> begin
(desugar_term env f)
end))))))))
and typars_of_binders : FStar_Parser_Env.env  ->  FStar_Parser_AST.binder Prims.list  ->  (FStar_Parser_Env.env * (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list) = (fun env bs -> (

let _63_1815 = (FStar_List.fold_left (fun _63_1796 b -> (match (_63_1796) with
| (env, out) -> begin
(

let tk = (desugar_binder env (

let _63_1798 = b
in {FStar_Parser_AST.b = _63_1798.FStar_Parser_AST.b; FStar_Parser_AST.brange = _63_1798.FStar_Parser_AST.brange; FStar_Parser_AST.blevel = FStar_Parser_AST.Formula; FStar_Parser_AST.aqual = _63_1798.FStar_Parser_AST.aqual}))
in (match (tk) with
| (Some (a), k) -> begin
(

let _63_1807 = (FStar_Parser_Env.push_bv env a)
in (match (_63_1807) with
| (env, a) -> begin
(

let a = (

let _63_1808 = a
in {FStar_Syntax_Syntax.ppname = _63_1808.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = _63_1808.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = k})
in (env, ((a, (trans_aqual b.FStar_Parser_AST.aqual)))::out))
end))
end
| _63_1812 -> begin
(Prims.raise (FStar_Syntax_Syntax.Error (("Unexpected binder", b.FStar_Parser_AST.brange))))
end))
end)) (env, []) bs)
in (match (_63_1815) with
| (env, tpars) -> begin
(env, (FStar_List.rev tpars))
end)))
and desugar_binder : FStar_Parser_Env.env  ->  FStar_Parser_AST.binder  ->  (FStar_Ident.ident Prims.option * FStar_Syntax_Syntax.term) = (fun env b -> (match (b.FStar_Parser_AST.b) with
| (FStar_Parser_AST.TAnnotated (x, t)) | (FStar_Parser_AST.Annotated (x, t)) -> begin
(let _154_677 = (desugar_typ env t)
in (Some (x), _154_677))
end
| FStar_Parser_AST.TVariable (x) -> begin
(let _154_678 = (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_type (FStar_Syntax_Syntax.U_unknown)) None x.FStar_Ident.idRange)
in (Some (x), _154_678))
end
| FStar_Parser_AST.NoName (t) -> begin
(let _154_679 = (desugar_typ env t)
in (None, _154_679))
end
| FStar_Parser_AST.Variable (x) -> begin
(Some (x), FStar_Syntax_Syntax.tun)
end))


let mk_data_discriminators : FStar_Syntax_Syntax.qualifier Prims.list  ->  FStar_Parser_Env.env  ->  FStar_Ident.lid  ->  (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list  ->  FStar_Syntax_Syntax.term  ->  FStar_Ident.lident Prims.list  ->  FStar_Syntax_Syntax.sigelt Prims.list = (fun quals env t tps k datas -> (

let quals = (fun q -> if ((FStar_All.pipe_left Prims.op_Negation env.FStar_Parser_Env.iface) || env.FStar_Parser_Env.admitted_iface) then begin
(FStar_List.append ((FStar_Syntax_Syntax.Assumption)::q) quals)
end else begin
(FStar_List.append q quals)
end)
in (

let binders = (let _154_695 = (let _154_694 = (FStar_Syntax_Util.arrow_formals k)
in (Prims.fst _154_694))
in (FStar_List.append tps _154_695))
in (

let p = (FStar_Ident.range_of_lid t)
in (

let _63_1842 = (FStar_Syntax_Util.args_of_binders binders)
in (match (_63_1842) with
| (binders, args) -> begin
(

let imp_binders = (FStar_All.pipe_right binders (FStar_List.map (fun _63_1846 -> (match (_63_1846) with
| (x, _63_1845) -> begin
(x, Some (FStar_Syntax_Syntax.imp_tag))
end))))
in (

let binders = (let _154_701 = (let _154_700 = (let _154_699 = (let _154_698 = (let _154_697 = (FStar_Syntax_Syntax.lid_as_fv t FStar_Syntax_Syntax.Delta_constant None)
in (FStar_Syntax_Syntax.fv_to_tm _154_697))
in (FStar_Syntax_Syntax.mk_Tm_app _154_698 args None p))
in (FStar_All.pipe_left FStar_Syntax_Syntax.null_binder _154_699))
in (_154_700)::[])
in (FStar_List.append imp_binders _154_701))
in (

let disc_type = (let _154_704 = (let _154_703 = (let _154_702 = (FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.bool_lid FStar_Syntax_Syntax.Delta_constant None)
in (FStar_Syntax_Syntax.fv_to_tm _154_702))
in (FStar_Syntax_Syntax.mk_Total _154_703))
in (FStar_Syntax_Util.arrow binders _154_704))
in (FStar_All.pipe_right datas (FStar_List.map (fun d -> (

let disc_name = (FStar_Syntax_Util.mk_discriminator d)
in (let _154_707 = (let _154_706 = (quals ((FStar_Syntax_Syntax.Logic)::(FStar_Syntax_Syntax.Discriminator (d))::[]))
in (disc_name, [], disc_type, _154_706, (FStar_Ident.range_of_lid disc_name)))
in FStar_Syntax_Syntax.Sig_declare_typ (_154_707)))))))))
end))))))


let mk_indexed_projectors : FStar_Syntax_Syntax.qualifier Prims.list  ->  FStar_Syntax_Syntax.fv_qual  ->  Prims.bool  ->  FStar_Parser_Env.env  ->  FStar_Ident.lident  ->  FStar_Ident.lid  ->  FStar_Syntax_Syntax.binders  ->  (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list  ->  FStar_Syntax_Syntax.binder Prims.list  ->  FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.sigelt Prims.list = (fun iquals fvq refine_domain env tc lid inductive_tps imp_tps fields t -> (

let p = (FStar_Ident.range_of_lid lid)
in (

let pos = (fun q -> (FStar_Syntax_Syntax.withinfo q FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n p))
in (

let projectee = (fun ptyp -> (FStar_Syntax_Syntax.gen_bv "projectee" (Some (p)) ptyp))
in (

let tps = (FStar_List.map2 (fun _63_1870 _63_1874 -> (match ((_63_1870, _63_1874)) with
| ((_63_1868, imp), (x, _63_1873)) -> begin
(x, imp)
end)) inductive_tps imp_tps)
in (

let _63_1975 = (

let _63_1878 = (FStar_Syntax_Util.head_and_args t)
in (match (_63_1878) with
| (head, args0) -> begin
(

let args = (

let rec arguments = (fun tps args -> (match ((tps, args)) with
| ([], _63_1884) -> begin
args
end
| (_63_1887, []) -> begin
(Prims.raise (FStar_Syntax_Syntax.Error (("Not enough arguments to type", (FStar_Ident.range_of_lid lid)))))
end
| (((_63_1892, Some (FStar_Syntax_Syntax.Implicit (_63_1894))))::tps', ((_63_1901, Some (FStar_Syntax_Syntax.Implicit (_63_1903))))::args') -> begin
(arguments tps' args')
end
| (((_63_1911, Some (FStar_Syntax_Syntax.Implicit (_63_1913))))::tps', ((_63_1921, _63_1923))::_63_1919) -> begin
(arguments tps' args)
end
| (((_63_1930, _63_1932))::_63_1928, ((a, Some (FStar_Syntax_Syntax.Implicit (_63_1939))))::_63_1936) -> begin
(Prims.raise (FStar_Syntax_Syntax.Error (("Unexpected implicit annotation on argument", a.FStar_Syntax_Syntax.pos))))
end
| (((_63_1947, _63_1949))::tps', ((_63_1954, _63_1956))::args') -> begin
(arguments tps' args')
end))
in (arguments inductive_tps args0))
in (

let indices = (FStar_All.pipe_right args (FStar_List.map (fun _63_1961 -> (let _154_739 = (FStar_Syntax_Syntax.new_bv (Some (p)) FStar_Syntax_Syntax.tun)
in (FStar_All.pipe_right _154_739 FStar_Syntax_Syntax.mk_binder)))))
in (

let arg_typ = (let _154_744 = (let _154_740 = (FStar_Syntax_Syntax.lid_as_fv tc FStar_Syntax_Syntax.Delta_constant None)
in (FStar_Syntax_Syntax.fv_to_tm _154_740))
in (let _154_743 = (FStar_All.pipe_right (FStar_List.append tps indices) (FStar_List.map (fun _63_1966 -> (match (_63_1966) with
| (x, imp) -> begin
(let _154_742 = (FStar_Syntax_Syntax.bv_to_name x)
in (_154_742, imp))
end))))
in (FStar_Syntax_Syntax.mk_Tm_app _154_744 _154_743 None p)))
in (

let arg_binder = if (not (refine_domain)) then begin
(let _154_745 = (projectee arg_typ)
in (FStar_Syntax_Syntax.mk_binder _154_745))
end else begin
(

let disc_name = (FStar_Syntax_Util.mk_discriminator lid)
in (

let x = (FStar_Syntax_Syntax.new_bv (Some (p)) arg_typ)
in (let _154_754 = (

let _63_1970 = (projectee arg_typ)
in (let _154_753 = (let _154_752 = (let _154_751 = (let _154_750 = (let _154_746 = (FStar_Ident.set_lid_range disc_name p)
in (FStar_Syntax_Syntax.fvar _154_746 FStar_Syntax_Syntax.Delta_equational None))
in (let _154_749 = (let _154_748 = (let _154_747 = (FStar_Syntax_Syntax.bv_to_name x)
in (FStar_All.pipe_left FStar_Syntax_Syntax.as_arg _154_747))
in (_154_748)::[])
in (FStar_Syntax_Syntax.mk_Tm_app _154_750 _154_749 None p)))
in (FStar_Syntax_Util.b2t _154_751))
in (FStar_Syntax_Util.refine x _154_752))
in {FStar_Syntax_Syntax.ppname = _63_1970.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = _63_1970.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = _154_753}))
in (FStar_Syntax_Syntax.mk_binder _154_754))))
end
in (arg_binder, indices)))))
end))
in (match (_63_1975) with
| (arg_binder, indices) -> begin
(

let arg_exp = (FStar_Syntax_Syntax.bv_to_name (Prims.fst arg_binder))
in (

let imp_binders = (let _154_756 = (FStar_All.pipe_right indices (FStar_List.map (fun _63_1980 -> (match (_63_1980) with
| (x, _63_1979) -> begin
(x, Some (FStar_Syntax_Syntax.imp_tag))
end))))
in (FStar_List.append imp_tps _154_756))
in (

let binders = (FStar_List.append imp_binders ((arg_binder)::[]))
in (

let arg = (FStar_Syntax_Util.arg_of_non_null_binder arg_binder)
in (

let subst = (FStar_All.pipe_right fields (FStar_List.mapi (fun i _63_1988 -> (match (_63_1988) with
| (a, _63_1987) -> begin
(

let _63_1992 = (FStar_Syntax_Util.mk_field_projector_name lid a i)
in (match (_63_1992) with
| (field_name, _63_1991) -> begin
(

let proj = (let _154_760 = (let _154_759 = (FStar_Syntax_Syntax.lid_as_fv field_name FStar_Syntax_Syntax.Delta_equational None)
in (FStar_Syntax_Syntax.fv_to_tm _154_759))
in (FStar_Syntax_Syntax.mk_Tm_app _154_760 ((arg)::[]) None p))
in FStar_Syntax_Syntax.NT ((a, proj)))
end))
end))))
in (

let ntps = (FStar_List.length tps)
in (

let all_params = (FStar_List.append imp_tps fields)
in (let _154_796 = (FStar_All.pipe_right fields (FStar_List.mapi (fun i _63_2001 -> (match (_63_2001) with
| (x, _63_2000) -> begin
(

let _63_2005 = (FStar_Syntax_Util.mk_field_projector_name lid x i)
in (match (_63_2005) with
| (field_name, _63_2004) -> begin
(

let t = (let _154_764 = (let _154_763 = (FStar_Syntax_Subst.subst subst x.FStar_Syntax_Syntax.sort)
in (FStar_Syntax_Syntax.mk_Total _154_763))
in (FStar_Syntax_Util.arrow binders _154_764))
in (

let only_decl = (((let _154_765 = (FStar_Parser_Env.current_module env)
in (FStar_Ident.lid_equals FStar_Syntax_Const.prims_lid _154_765)) || (fvq <> FStar_Syntax_Syntax.Data_ctor)) || (let _154_767 = (let _154_766 = (FStar_Parser_Env.current_module env)
in _154_766.FStar_Ident.str)
in (FStar_Options.dont_gen_projectors _154_767)))
in (

let no_decl = (FStar_Syntax_Syntax.is_type x.FStar_Syntax_Syntax.sort)
in (

let quals = (fun q -> if only_decl then begin
(FStar_Syntax_Syntax.Assumption)::q
end else begin
q
end)
in (

let quals = (quals ((FStar_Syntax_Syntax.Projector ((lid, x.FStar_Syntax_Syntax.ppname)))::iquals))
in (

let decl = FStar_Syntax_Syntax.Sig_declare_typ ((field_name, [], t, quals, (FStar_Ident.range_of_lid field_name)))
in if only_decl then begin
(decl)::[]
end else begin
(

let projection = (FStar_Syntax_Syntax.gen_bv x.FStar_Syntax_Syntax.ppname.FStar_Ident.idText None FStar_Syntax_Syntax.tun)
in (

let arg_pats = (FStar_All.pipe_right all_params (FStar_List.mapi (fun j _63_2017 -> (match (_63_2017) with
| (x, imp) -> begin
(

let b = (FStar_Syntax_Syntax.is_implicit imp)
in if ((i + ntps) = j) then begin
(let _154_772 = (pos (FStar_Syntax_Syntax.Pat_var (projection)))
in (_154_772, b))
end else begin
if (b && (j < ntps)) then begin
(let _154_776 = (let _154_775 = (let _154_774 = (let _154_773 = (FStar_Syntax_Syntax.gen_bv x.FStar_Syntax_Syntax.ppname.FStar_Ident.idText None FStar_Syntax_Syntax.tun)
in (_154_773, FStar_Syntax_Syntax.tun))
in FStar_Syntax_Syntax.Pat_dot_term (_154_774))
in (pos _154_775))
in (_154_776, b))
end else begin
(let _154_779 = (let _154_778 = (let _154_777 = (FStar_Syntax_Syntax.gen_bv x.FStar_Syntax_Syntax.ppname.FStar_Ident.idText None FStar_Syntax_Syntax.tun)
in FStar_Syntax_Syntax.Pat_wild (_154_777))
in (pos _154_778))
in (_154_779, b))
end
end)
end))))
in (

let pat = (let _154_784 = (let _154_782 = (let _154_781 = (let _154_780 = (FStar_Syntax_Syntax.lid_as_fv lid FStar_Syntax_Syntax.Delta_constant (Some (fvq)))
in (_154_780, arg_pats))
in FStar_Syntax_Syntax.Pat_cons (_154_781))
in (FStar_All.pipe_right _154_782 pos))
in (let _154_783 = (FStar_Syntax_Syntax.bv_to_name projection)
in (_154_784, None, _154_783)))
in (

let body = (let _154_788 = (let _154_787 = (let _154_786 = (let _154_785 = (FStar_Syntax_Util.branch pat)
in (_154_785)::[])
in (arg_exp, _154_786))
in FStar_Syntax_Syntax.Tm_match (_154_787))
in (FStar_Syntax_Syntax.mk _154_788 None p))
in (

let imp = (no_annot_abs binders body)
in (

let dd = if (FStar_All.pipe_right quals (FStar_List.contains FStar_Syntax_Syntax.Abstract)) then begin
FStar_Syntax_Syntax.Delta_abstract (FStar_Syntax_Syntax.Delta_equational)
end else begin
FStar_Syntax_Syntax.Delta_equational
end
in (

let lb = (let _154_790 = (let _154_789 = (FStar_Syntax_Syntax.lid_as_fv field_name dd None)
in FStar_Util.Inr (_154_789))
in {FStar_Syntax_Syntax.lbname = _154_790; FStar_Syntax_Syntax.lbunivs = []; FStar_Syntax_Syntax.lbtyp = FStar_Syntax_Syntax.tun; FStar_Syntax_Syntax.lbeff = FStar_Syntax_Const.effect_Tot_lid; FStar_Syntax_Syntax.lbdef = imp})
in (

let impl = (let _154_795 = (let _154_794 = (let _154_793 = (let _154_792 = (FStar_All.pipe_right lb.FStar_Syntax_Syntax.lbname FStar_Util.right)
in (FStar_All.pipe_right _154_792 (fun fv -> fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v)))
in (_154_793)::[])
in ((false, (lb)::[]), p, _154_794, quals))
in FStar_Syntax_Syntax.Sig_let (_154_795))
in if no_decl then begin
(impl)::[]
end else begin
(decl)::(impl)::[]
end))))))))
end))))))
end))
end))))
in (FStar_All.pipe_right _154_796 FStar_List.flatten)))))))))
end)))))))


let mk_data_projectors : FStar_Syntax_Syntax.qualifier Prims.list  ->  FStar_Parser_Env.env  ->  (FStar_Syntax_Syntax.binders * FStar_Syntax_Syntax.sigelt)  ->  FStar_Syntax_Syntax.sigelt Prims.list = (fun iquals env _63_2031 -> (match (_63_2031) with
| (inductive_tps, se) -> begin
(match (se) with
| FStar_Syntax_Syntax.Sig_datacon (lid, _63_2034, t, l, n, quals, _63_2040, _63_2042) when (not ((FStar_Ident.lid_equals lid FStar_Syntax_Const.lexcons_lid))) -> begin
(

let refine_domain = if (FStar_All.pipe_right quals (FStar_Util.for_some (fun _63_10 -> (match (_63_10) with
| FStar_Syntax_Syntax.RecordConstructor (_63_2047) -> begin
true
end
| _63_2050 -> begin
false
end)))) then begin
false
end else begin
(match ((FStar_Parser_Env.find_all_datacons env l)) with
| Some (l) -> begin
((FStar_List.length l) > 1)
end
| _63_2054 -> begin
true
end)
end
in (

let _63_2058 = (FStar_Syntax_Util.arrow_formals t)
in (match (_63_2058) with
| (formals, cod) -> begin
(match (formals) with
| [] -> begin
[]
end
| _63_2061 -> begin
(

let fv_qual = (match ((FStar_Util.find_map quals (fun _63_11 -> (match (_63_11) with
| FStar_Syntax_Syntax.RecordConstructor (fns) -> begin
Some (FStar_Syntax_Syntax.Record_ctor ((lid, fns)))
end
| _63_2066 -> begin
None
end)))) with
| None -> begin
FStar_Syntax_Syntax.Data_ctor
end
| Some (q) -> begin
q
end)
in (

let iquals = if (FStar_List.contains FStar_Syntax_Syntax.Abstract iquals) then begin
(FStar_Syntax_Syntax.Private)::iquals
end else begin
iquals
end
in (

let _63_2074 = (FStar_Util.first_N n formals)
in (match (_63_2074) with
| (tps, rest) -> begin
(mk_indexed_projectors iquals fv_qual refine_domain env l lid inductive_tps tps rest cod)
end))))
end)
end)))
end
| _63_2076 -> begin
[]
end)
end))


let mk_typ_abbrev : FStar_Ident.lident  ->  FStar_Syntax_Syntax.univ_name Prims.list  ->  (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list  ->  FStar_Syntax_Syntax.typ  ->  FStar_Syntax_Syntax.term  ->  FStar_Ident.lident Prims.list  ->  FStar_Syntax_Syntax.qualifier Prims.list  ->  FStar_Range.range  ->  FStar_Syntax_Syntax.sigelt = (fun lid uvs typars k t lids quals rng -> (

let dd = if (FStar_All.pipe_right quals (FStar_List.contains FStar_Syntax_Syntax.Abstract)) then begin
(let _154_821 = (incr_delta_qualifier t)
in FStar_Syntax_Syntax.Delta_abstract (_154_821))
end else begin
(incr_delta_qualifier t)
end
in (

let lb = (let _154_826 = (let _154_822 = (FStar_Syntax_Syntax.lid_as_fv lid dd None)
in FStar_Util.Inr (_154_822))
in (let _154_825 = (let _154_823 = (FStar_Syntax_Syntax.mk_Total k)
in (FStar_Syntax_Util.arrow typars _154_823))
in (let _154_824 = (no_annot_abs typars t)
in {FStar_Syntax_Syntax.lbname = _154_826; FStar_Syntax_Syntax.lbunivs = uvs; FStar_Syntax_Syntax.lbtyp = _154_825; FStar_Syntax_Syntax.lbeff = FStar_Syntax_Const.effect_Tot_lid; FStar_Syntax_Syntax.lbdef = _154_824})))
in FStar_Syntax_Syntax.Sig_let (((false, (lb)::[]), rng, lids, quals)))))


let rec desugar_tycon : FStar_Parser_Env.env  ->  FStar_Range.range  ->  FStar_Syntax_Syntax.qualifier Prims.list  ->  FStar_Parser_AST.tycon Prims.list  ->  (env_t * FStar_Syntax_Syntax.sigelts) = (fun env rng quals tcs -> (

let tycon_id = (fun _63_12 -> (match (_63_12) with
| (FStar_Parser_AST.TyconAbstract (id, _, _)) | (FStar_Parser_AST.TyconAbbrev (id, _, _, _)) | (FStar_Parser_AST.TyconRecord (id, _, _, _)) | (FStar_Parser_AST.TyconVariant (id, _, _, _)) -> begin
id
end))
in (

let binder_to_term = (fun b -> (match (b.FStar_Parser_AST.b) with
| (FStar_Parser_AST.Annotated (x, _)) | (FStar_Parser_AST.Variable (x)) -> begin
(let _154_840 = (let _154_839 = (FStar_Ident.lid_of_ids ((x)::[]))
in FStar_Parser_AST.Var (_154_839))
in (FStar_Parser_AST.mk_term _154_840 x.FStar_Ident.idRange FStar_Parser_AST.Expr))
end
| (FStar_Parser_AST.TAnnotated (a, _)) | (FStar_Parser_AST.TVariable (a)) -> begin
(FStar_Parser_AST.mk_term (FStar_Parser_AST.Tvar (a)) a.FStar_Ident.idRange FStar_Parser_AST.Type)
end
| FStar_Parser_AST.NoName (t) -> begin
t
end))
in (

let tot = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Syntax_Const.effect_Tot_lid)) rng FStar_Parser_AST.Expr)
in (

let with_constructor_effect = (fun t -> (FStar_Parser_AST.mk_term (FStar_Parser_AST.App ((tot, t, FStar_Parser_AST.Nothing))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level))
in (

let apply_binders = (fun t binders -> (

let imp_of_aqual = (fun b -> (match (b.FStar_Parser_AST.aqual) with
| Some (FStar_Parser_AST.Implicit) -> begin
FStar_Parser_AST.Hash
end
| _63_2151 -> begin
FStar_Parser_AST.Nothing
end))
in (FStar_List.fold_left (fun out b -> (let _154_853 = (let _154_852 = (let _154_851 = (binder_to_term b)
in (out, _154_851, (imp_of_aqual b)))
in FStar_Parser_AST.App (_154_852))
in (FStar_Parser_AST.mk_term _154_853 out.FStar_Parser_AST.range out.FStar_Parser_AST.level))) t binders)))
in (

let tycon_record_as_variant = (fun _63_13 -> (match (_63_13) with
| FStar_Parser_AST.TyconRecord (id, parms, kopt, fields) -> begin
(

let constrName = (FStar_Ident.mk_ident ((Prims.strcat "Mk" id.FStar_Ident.idText), id.FStar_Ident.idRange))
in (

let mfields = (FStar_List.map (fun _63_2164 -> (match (_63_2164) with
| (x, t) -> begin
(FStar_Parser_AST.mk_binder (FStar_Parser_AST.Annotated (((FStar_Syntax_Util.mangle_field_name x), t))) x.FStar_Ident.idRange FStar_Parser_AST.Expr None)
end)) fields)
in (

let result = (let _154_859 = (let _154_858 = (let _154_857 = (FStar_Ident.lid_of_ids ((id)::[]))
in FStar_Parser_AST.Var (_154_857))
in (FStar_Parser_AST.mk_term _154_858 id.FStar_Ident.idRange FStar_Parser_AST.Type))
in (apply_binders _154_859 parms))
in (

let constrTyp = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Product ((mfields, (with_constructor_effect result)))) id.FStar_Ident.idRange FStar_Parser_AST.Type)
in (let _154_861 = (FStar_All.pipe_right fields (FStar_List.map (fun _63_2171 -> (match (_63_2171) with
| (x, _63_2170) -> begin
(FStar_Parser_Env.qualify env x)
end))))
in (FStar_Parser_AST.TyconVariant ((id, parms, kopt, ((constrName, Some (constrTyp), false))::[])), _154_861))))))
end
| _63_2173 -> begin
(FStar_All.failwith "impossible")
end))
in (

let desugar_abstract_tc = (fun quals _env mutuals _63_14 -> (match (_63_14) with
| FStar_Parser_AST.TyconAbstract (id, binders, kopt) -> begin
(

let _63_2187 = (typars_of_binders _env binders)
in (match (_63_2187) with
| (_env', typars) -> begin
(

let k = (match (kopt) with
| None -> begin
FStar_Syntax_Util.ktype
end
| Some (k) -> begin
(desugar_term _env' k)
end)
in (

let tconstr = (let _154_872 = (let _154_871 = (let _154_870 = (FStar_Ident.lid_of_ids ((id)::[]))
in FStar_Parser_AST.Var (_154_870))
in (FStar_Parser_AST.mk_term _154_871 id.FStar_Ident.idRange FStar_Parser_AST.Type))
in (apply_binders _154_872 binders))
in (

let qlid = (FStar_Parser_Env.qualify _env id)
in (

let typars = (FStar_Syntax_Subst.close_binders typars)
in (

let k = (FStar_Syntax_Subst.close typars k)
in (

let se = FStar_Syntax_Syntax.Sig_inductive_typ ((qlid, [], typars, k, mutuals, [], quals, rng))
in (

let _env = (FStar_Parser_Env.push_top_level_rec_binding _env id FStar_Syntax_Syntax.Delta_constant)
in (

let _env2 = (FStar_Parser_Env.push_top_level_rec_binding _env' id FStar_Syntax_Syntax.Delta_constant)
in (_env, _env2, se, tconstr)))))))))
end))
end
| _63_2200 -> begin
(FStar_All.failwith "Unexpected tycon")
end))
in (

let push_tparams = (fun env bs -> (

let _63_2215 = (FStar_List.fold_left (fun _63_2206 _63_2209 -> (match ((_63_2206, _63_2209)) with
| ((env, tps), (x, imp)) -> begin
(

let _63_2212 = (FStar_Parser_Env.push_bv env x.FStar_Syntax_Syntax.ppname)
in (match (_63_2212) with
| (env, y) -> begin
(env, ((y, imp))::tps)
end))
end)) (env, []) bs)
in (match (_63_2215) with
| (env, bs) -> begin
(env, (FStar_List.rev bs))
end)))
in (match (tcs) with
| (FStar_Parser_AST.TyconAbstract (id, bs, kopt))::[] -> begin
(

let kopt = (match (kopt) with
| None -> begin
(let _154_879 = (tm_type_z id.FStar_Ident.idRange)
in Some (_154_879))
end
| _63_2224 -> begin
kopt
end)
in (

let tc = FStar_Parser_AST.TyconAbstract ((id, bs, kopt))
in (

let _63_2234 = (desugar_abstract_tc quals env [] tc)
in (match (_63_2234) with
| (_63_2228, _63_2230, se, _63_2233) -> begin
(

let se = (match (se) with
| FStar_Syntax_Syntax.Sig_inductive_typ (l, _63_2237, typars, k, [], [], quals, rng) -> begin
(

let quals = if (FStar_All.pipe_right quals (FStar_List.contains FStar_Syntax_Syntax.Assumption)) then begin
quals
end else begin
(

let _63_2246 = (let _154_881 = (FStar_Range.string_of_range rng)
in (let _154_880 = (FStar_Syntax_Print.lid_to_string l)
in (FStar_Util.print2 "%s (Warning): Adding an implicit \'assume new\' qualifier on %s\n" _154_881 _154_880)))
in (FStar_Syntax_Syntax.Assumption)::(FStar_Syntax_Syntax.New)::quals)
end
in (

let t = (match (typars) with
| [] -> begin
k
end
| _63_2251 -> begin
(let _154_884 = (let _154_883 = (let _154_882 = (FStar_Syntax_Syntax.mk_Total k)
in (typars, _154_882))
in FStar_Syntax_Syntax.Tm_arrow (_154_883))
in (FStar_Syntax_Syntax.mk _154_884 None rng))
end)
in FStar_Syntax_Syntax.Sig_declare_typ ((l, [], t, quals, rng))))
end
| _63_2254 -> begin
se
end)
in (

let env = (FStar_Parser_Env.push_sigelt env se)
in (env, (se)::[])))
end))))
end
| (FStar_Parser_AST.TyconAbbrev (id, binders, kopt, t))::[] -> begin
(

let _63_2266 = (typars_of_binders env binders)
in (match (_63_2266) with
| (env', typars) -> begin
(

let k = (match (kopt) with
| None -> begin
if (FStar_Util.for_some (fun _63_15 -> (match (_63_15) with
| FStar_Syntax_Syntax.Effect -> begin
true
end
| _63_2271 -> begin
false
end)) quals) then begin
FStar_Syntax_Syntax.teff
end else begin
FStar_Syntax_Syntax.tun
end
end
| Some (k) -> begin
(desugar_term env' k)
end)
in (

let t0 = t
in (

let quals = if (FStar_All.pipe_right quals (FStar_Util.for_some (fun _63_16 -> (match (_63_16) with
| FStar_Syntax_Syntax.Logic -> begin
true
end
| _63_2279 -> begin
false
end)))) then begin
quals
end else begin
if (t0.FStar_Parser_AST.level = FStar_Parser_AST.Formula) then begin
(FStar_Syntax_Syntax.Logic)::quals
end else begin
quals
end
end
in (

let se = if (FStar_All.pipe_right quals (FStar_List.contains FStar_Syntax_Syntax.Effect)) then begin
(

let c = (desugar_comp t.FStar_Parser_AST.range false env' t)
in (

let typars = (FStar_Syntax_Subst.close_binders typars)
in (

let c = (FStar_Syntax_Subst.close_comp typars c)
in (let _154_890 = (let _154_889 = (FStar_Parser_Env.qualify env id)
in (let _154_888 = (FStar_All.pipe_right quals (FStar_List.filter (fun _63_17 -> (match (_63_17) with
| FStar_Syntax_Syntax.Effect -> begin
false
end
| _63_2287 -> begin
true
end))))
in (_154_889, [], typars, c, _154_888, rng)))
in FStar_Syntax_Syntax.Sig_effect_abbrev (_154_890)))))
end else begin
(

let t = (desugar_typ env' t)
in (

let nm = (FStar_Parser_Env.qualify env id)
in (mk_typ_abbrev nm [] typars k t ((nm)::[]) quals rng)))
end
in (

let env = (FStar_Parser_Env.push_sigelt env se)
in (env, (se)::[]))))))
end))
end
| (FStar_Parser_AST.TyconRecord (_63_2293))::[] -> begin
(

let trec = (FStar_List.hd tcs)
in (

let _63_2299 = (tycon_record_as_variant trec)
in (match (_63_2299) with
| (t, fs) -> begin
(desugar_tycon env rng ((FStar_Syntax_Syntax.RecordType (fs))::quals) ((t)::[]))
end)))
end
| (_63_2303)::_63_2301 -> begin
(

let env0 = env
in (

let mutuals = (FStar_List.map (fun x -> (FStar_All.pipe_left (FStar_Parser_Env.qualify env) (tycon_id x))) tcs)
in (

let rec collect_tcs = (fun quals et tc -> (

let _63_2314 = et
in (match (_63_2314) with
| (env, tcs) -> begin
(match (tc) with
| FStar_Parser_AST.TyconRecord (_63_2316) -> begin
(

let trec = tc
in (

let _63_2321 = (tycon_record_as_variant trec)
in (match (_63_2321) with
| (t, fs) -> begin
(collect_tcs ((FStar_Syntax_Syntax.RecordType (fs))::quals) (env, tcs) t)
end)))
end
| FStar_Parser_AST.TyconVariant (id, binders, kopt, constructors) -> begin
(

let _63_2333 = (desugar_abstract_tc quals env mutuals (FStar_Parser_AST.TyconAbstract ((id, binders, kopt))))
in (match (_63_2333) with
| (env, _63_2330, se, tconstr) -> begin
(env, (FStar_Util.Inl ((se, constructors, tconstr, quals)))::tcs)
end))
end
| FStar_Parser_AST.TyconAbbrev (id, binders, kopt, t) -> begin
(

let _63_2345 = (desugar_abstract_tc quals env mutuals (FStar_Parser_AST.TyconAbstract ((id, binders, kopt))))
in (match (_63_2345) with
| (env, _63_2342, se, tconstr) -> begin
(env, (FStar_Util.Inr ((se, t, quals)))::tcs)
end))
end
| _63_2347 -> begin
(FStar_All.failwith "Unrecognized mutual type definition")
end)
end)))
in (

let _63_2350 = (FStar_List.fold_left (collect_tcs quals) (env, []) tcs)
in (match (_63_2350) with
| (env, tcs) -> begin
(

let tcs = (FStar_List.rev tcs)
in (

let tps_sigelts = (FStar_All.pipe_right tcs (FStar_List.collect (fun _63_19 -> (match (_63_19) with
| FStar_Util.Inr (FStar_Syntax_Syntax.Sig_inductive_typ (id, uvs, tpars, k, _63_2358, _63_2360, _63_2362, _63_2364), t, quals) -> begin
(

let _63_2374 = (push_tparams env tpars)
in (match (_63_2374) with
| (env_tps, _63_2373) -> begin
(

let t = (desugar_term env_tps t)
in (let _154_900 = (let _154_899 = (mk_typ_abbrev id uvs tpars k t ((id)::[]) quals rng)
in ([], _154_899))
in (_154_900)::[]))
end))
end
| FStar_Util.Inl (FStar_Syntax_Syntax.Sig_inductive_typ (tname, univs, tpars, k, mutuals, _63_2382, tags, _63_2385), constrs, tconstr, quals) -> begin
(

let tycon = (tname, tpars, k)
in (

let _63_2396 = (push_tparams env tpars)
in (match (_63_2396) with
| (env_tps, tps) -> begin
(

let data_tpars = (FStar_List.map (fun _63_2400 -> (match (_63_2400) with
| (x, _63_2399) -> begin
(x, Some (FStar_Syntax_Syntax.Implicit (true)))
end)) tps)
in (

let _63_2424 = (let _154_912 = (FStar_All.pipe_right constrs (FStar_List.map (fun _63_2405 -> (match (_63_2405) with
| (id, topt, of_notation) -> begin
(

let t = if of_notation then begin
(match (topt) with
| Some (t) -> begin
(FStar_Parser_AST.mk_term (FStar_Parser_AST.Product ((((FStar_Parser_AST.mk_binder (FStar_Parser_AST.NoName (t)) t.FStar_Parser_AST.range t.FStar_Parser_AST.level None))::[], tconstr))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)
end
| None -> begin
tconstr
end)
end else begin
(match (topt) with
| None -> begin
(FStar_All.failwith "Impossible")
end
| Some (t) -> begin
t
end)
end
in (

let t = (let _154_904 = (FStar_Parser_Env.default_total env_tps)
in (let _154_903 = (close env_tps t)
in (desugar_term _154_904 _154_903)))
in (

let name = (FStar_Parser_Env.qualify env id)
in (

let quals = (FStar_All.pipe_right tags (FStar_List.collect (fun _63_18 -> (match (_63_18) with
| FStar_Syntax_Syntax.RecordType (fns) -> begin
(FStar_Syntax_Syntax.RecordConstructor (fns))::[]
end
| _63_2419 -> begin
[]
end))))
in (

let ntps = (FStar_List.length data_tpars)
in (let _154_911 = (let _154_910 = (let _154_909 = (let _154_908 = (let _154_907 = (let _154_906 = (FStar_All.pipe_right t FStar_Syntax_Util.name_function_binders)
in (FStar_Syntax_Syntax.mk_Total _154_906))
in (FStar_Syntax_Util.arrow data_tpars _154_907))
in (name, univs, _154_908, tname, ntps, quals, mutuals, rng))
in FStar_Syntax_Syntax.Sig_datacon (_154_909))
in (tps, _154_910))
in (name, _154_911)))))))
end))))
in (FStar_All.pipe_left FStar_List.split _154_912))
in (match (_63_2424) with
| (constrNames, constrs) -> begin
(([], FStar_Syntax_Syntax.Sig_inductive_typ ((tname, univs, tpars, k, mutuals, constrNames, tags, rng))))::constrs
end)))
end)))
end
| _63_2426 -> begin
(FStar_All.failwith "impossible")
end))))
in (

let sigelts = (FStar_All.pipe_right tps_sigelts (FStar_List.map Prims.snd))
in (

let bundle = (let _154_914 = (let _154_913 = (FStar_List.collect FStar_Syntax_Util.lids_of_sigelt sigelts)
in (sigelts, quals, _154_913, rng))
in FStar_Syntax_Syntax.Sig_bundle (_154_914))
in (

let env = (FStar_Parser_Env.push_sigelt env0 bundle)
in (

let data_ops = (FStar_All.pipe_right tps_sigelts (FStar_List.collect (mk_data_projectors quals env)))
in (

let discs = (FStar_All.pipe_right sigelts (FStar_List.collect (fun _63_20 -> (match (_63_20) with
| FStar_Syntax_Syntax.Sig_inductive_typ (tname, _63_2435, tps, k, _63_2439, constrs, quals, _63_2443) when ((FStar_List.length constrs) > 1) -> begin
(

let quals = if (FStar_List.contains FStar_Syntax_Syntax.Abstract quals) then begin
(FStar_Syntax_Syntax.Private)::quals
end else begin
quals
end
in (mk_data_discriminators quals env tname tps k constrs))
end
| _63_2448 -> begin
[]
end))))
in (

let ops = (FStar_List.append discs data_ops)
in (

let env = (FStar_List.fold_left FStar_Parser_Env.push_sigelt env ops)
in (env, (FStar_List.append ((bundle)::[]) ops)))))))))))
end)))))
end
| [] -> begin
(FStar_All.failwith "impossible")
end))))))))))


let desugar_binders : FStar_Parser_Env.env  ->  FStar_Parser_AST.binder Prims.list  ->  (FStar_Parser_Env.env * FStar_Syntax_Syntax.binder Prims.list) = (fun env binders -> (

let _63_2472 = (FStar_List.fold_left (fun _63_2457 b -> (match (_63_2457) with
| (env, binders) -> begin
(match ((desugar_binder env b)) with
| (Some (a), k) -> begin
(

let _63_2465 = (FStar_Parser_Env.push_bv env a)
in (match (_63_2465) with
| (env, a) -> begin
(let _154_923 = (let _154_922 = (FStar_Syntax_Syntax.mk_binder (

let _63_2466 = a
in {FStar_Syntax_Syntax.ppname = _63_2466.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = _63_2466.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = k}))
in (_154_922)::binders)
in (env, _154_923))
end))
end
| _63_2469 -> begin
(Prims.raise (FStar_Syntax_Syntax.Error (("Missing name in binder", b.FStar_Parser_AST.brange))))
end)
end)) (env, []) binders)
in (match (_63_2472) with
| (env, binders) -> begin
(env, (FStar_List.rev binders))
end)))


let rec desugar_effect : FStar_Parser_Env.env  ->  FStar_Parser_AST.decl  ->  FStar_Parser_AST.qualifiers  ->  FStar_Ident.ident  ->  FStar_Parser_AST.binder Prims.list  ->  FStar_Parser_AST.term  ->  FStar_Parser_AST.decl Prims.list  ->  (FStar_Ident.lident  ->  FStar_Syntax_Syntax.qualifier Prims.list  ->  FStar_Syntax_Syntax.binders  ->  FStar_Syntax_Syntax.term  ->  (Prims.string  ->  (FStar_Ident.ident Prims.list * FStar_Syntax_Syntax.term))  ->  FStar_Syntax_Syntax.sigelt)  ->  (FStar_Parser_Env.env * FStar_Syntax_Syntax.sigelt Prims.list) = (fun env d quals eff_name eff_binders eff_kind eff_decls mk -> (

let env0 = env
in (

let env = (FStar_Parser_Env.enter_monad_scope env eff_name)
in (

let _63_2485 = (desugar_binders env eff_binders)
in (match (_63_2485) with
| (env, binders) -> begin
(

let eff_k = (let _154_975 = (FStar_Parser_Env.default_total env)
in (desugar_term _154_975 eff_kind))
in (

let _63_2496 = (FStar_All.pipe_right eff_decls (FStar_List.fold_left (fun _63_2489 decl -> (match (_63_2489) with
| (env, out) -> begin
(

let _63_2493 = (desugar_decl env decl)
in (match (_63_2493) with
| (env, ses) -> begin
(let _154_979 = (let _154_978 = (FStar_List.hd ses)
in (_154_978)::out)
in (env, _154_979))
end))
end)) (env, [])))
in (match (_63_2496) with
| (env, decls) -> begin
(

let binders = (FStar_Syntax_Subst.close_binders binders)
in (

let eff_k = (FStar_Syntax_Subst.close binders eff_k)
in (

let lookup = (fun s -> (

let l = (FStar_Parser_Env.qualify env (FStar_Ident.mk_ident (s, d.FStar_Parser_AST.drange)))
in (let _154_983 = (let _154_982 = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_definition env) l)
in (FStar_All.pipe_left (FStar_Syntax_Subst.close binders) _154_982))
in ([], _154_983))))
in (

let mname = (FStar_Parser_Env.qualify env0 eff_name)
in (

let qualifiers = (FStar_List.map (trans_qual d.FStar_Parser_AST.drange) quals)
in (

let se = (mk mname qualifiers binders eff_k lookup)
in (

let env = (FStar_Parser_Env.push_sigelt env0 se)
in (env, (se)::[]))))))))
end)))
end)))))
and desugar_decl : env_t  ->  FStar_Parser_AST.decl  ->  (env_t * FStar_Syntax_Syntax.sigelts) = (fun env d -> (

let trans_qual = (trans_qual d.FStar_Parser_AST.drange)
in (match (d.FStar_Parser_AST.d) with
| FStar_Parser_AST.Pragma (p) -> begin
(

let se = FStar_Syntax_Syntax.Sig_pragma (((trans_pragma p), d.FStar_Parser_AST.drange))
in (env, (se)::[]))
end
| FStar_Parser_AST.TopLevelModule (_63_2513) -> begin
(Prims.raise (FStar_Syntax_Syntax.Error (("Multiple modules in a file are no longer supported", d.FStar_Parser_AST.drange))))
end
| FStar_Parser_AST.Open (lid) -> begin
(

let env = (FStar_Parser_Env.push_namespace env lid)
in (env, []))
end
| FStar_Parser_AST.ModuleAbbrev (x, l) -> begin
(let _154_987 = (FStar_Parser_Env.push_module_abbrev env x l)
in (_154_987, []))
end
| FStar_Parser_AST.Tycon (qual, tcs) -> begin
(let _154_988 = (FStar_List.map trans_qual qual)
in (desugar_tycon env d.FStar_Parser_AST.drange _154_988 tcs))
end
| FStar_Parser_AST.ToplevelLet (quals, isrec, lets) -> begin
(match ((let _154_990 = (let _154_989 = (desugar_term_maybe_top true env (FStar_Parser_AST.mk_term (FStar_Parser_AST.Let ((isrec, lets, (FStar_Parser_AST.mk_term (FStar_Parser_AST.Const (FStar_Const.Const_unit)) d.FStar_Parser_AST.drange FStar_Parser_AST.Expr)))) d.FStar_Parser_AST.drange FStar_Parser_AST.Expr))
in (FStar_All.pipe_left FStar_Syntax_Subst.compress _154_989))
in _154_990.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_let (lbs, _63_2533) -> begin
(

let fvs = (FStar_All.pipe_right (Prims.snd lbs) (FStar_List.map (fun lb -> (FStar_Util.right lb.FStar_Syntax_Syntax.lbname))))
in (

let quals = (match (quals) with
| (_63_2541)::_63_2539 -> begin
(FStar_List.map trans_qual quals)
end
| _63_2544 -> begin
(FStar_All.pipe_right (Prims.snd lbs) (FStar_List.collect (fun _63_21 -> (match (_63_21) with
| {FStar_Syntax_Syntax.lbname = FStar_Util.Inl (_63_2555); FStar_Syntax_Syntax.lbunivs = _63_2553; FStar_Syntax_Syntax.lbtyp = _63_2551; FStar_Syntax_Syntax.lbeff = _63_2549; FStar_Syntax_Syntax.lbdef = _63_2547} -> begin
[]
end
| {FStar_Syntax_Syntax.lbname = FStar_Util.Inr (fv); FStar_Syntax_Syntax.lbunivs = _63_2565; FStar_Syntax_Syntax.lbtyp = _63_2563; FStar_Syntax_Syntax.lbeff = _63_2561; FStar_Syntax_Syntax.lbdef = _63_2559} -> begin
(FStar_Parser_Env.lookup_letbinding_quals env fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v)
end))))
end)
in (

let quals = if (FStar_All.pipe_right lets (FStar_Util.for_some (fun _63_2573 -> (match (_63_2573) with
| (_63_2571, t) -> begin
(t.FStar_Parser_AST.level = FStar_Parser_AST.Formula)
end)))) then begin
(FStar_Syntax_Syntax.Logic)::quals
end else begin
quals
end
in (

let lbs = if (FStar_All.pipe_right quals (FStar_List.contains FStar_Syntax_Syntax.Abstract)) then begin
(let _154_995 = (FStar_All.pipe_right (Prims.snd lbs) (FStar_List.map (fun lb -> (

let fv = (FStar_Util.right lb.FStar_Syntax_Syntax.lbname)
in (

let _63_2577 = lb
in {FStar_Syntax_Syntax.lbname = FStar_Util.Inr ((

let _63_2579 = fv
in {FStar_Syntax_Syntax.fv_name = _63_2579.FStar_Syntax_Syntax.fv_name; FStar_Syntax_Syntax.fv_delta = FStar_Syntax_Syntax.Delta_abstract (fv.FStar_Syntax_Syntax.fv_delta); FStar_Syntax_Syntax.fv_qual = _63_2579.FStar_Syntax_Syntax.fv_qual})); FStar_Syntax_Syntax.lbunivs = _63_2577.FStar_Syntax_Syntax.lbunivs; FStar_Syntax_Syntax.lbtyp = _63_2577.FStar_Syntax_Syntax.lbtyp; FStar_Syntax_Syntax.lbeff = _63_2577.FStar_Syntax_Syntax.lbeff; FStar_Syntax_Syntax.lbdef = _63_2577.FStar_Syntax_Syntax.lbdef})))))
in ((Prims.fst lbs), _154_995))
end else begin
lbs
end
in (

let s = (let _154_998 = (let _154_997 = (FStar_All.pipe_right fvs (FStar_List.map (fun fv -> fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v)))
in (lbs, d.FStar_Parser_AST.drange, _154_997, quals))
in FStar_Syntax_Syntax.Sig_let (_154_998))
in (

let env = (FStar_Parser_Env.push_sigelt env s)
in (env, (s)::[])))))))
end
| _63_2586 -> begin
(FStar_All.failwith "Desugaring a let did not produce a let")
end)
end
| FStar_Parser_AST.Main (t) -> begin
(

let e = (desugar_term env t)
in (

let se = FStar_Syntax_Syntax.Sig_main ((e, d.FStar_Parser_AST.drange))
in (env, (se)::[])))
end
| FStar_Parser_AST.Assume (atag, id, t) -> begin
(

let f = (desugar_formula env t)
in (let _154_1002 = (let _154_1001 = (let _154_1000 = (let _154_999 = (FStar_Parser_Env.qualify env id)
in (_154_999, f, (FStar_Syntax_Syntax.Assumption)::[], d.FStar_Parser_AST.drange))
in FStar_Syntax_Syntax.Sig_assume (_154_1000))
in (_154_1001)::[])
in (env, _154_1002)))
end
| FStar_Parser_AST.Val (quals, id, t) -> begin
(

let t = (let _154_1003 = (close_fun env t)
in (desugar_term env _154_1003))
in (

let quals = if (env.FStar_Parser_Env.iface && env.FStar_Parser_Env.admitted_iface) then begin
(FStar_Parser_AST.Assumption)::quals
end else begin
quals
end
in (

let se = (let _154_1006 = (let _154_1005 = (FStar_Parser_Env.qualify env id)
in (let _154_1004 = (FStar_List.map trans_qual quals)
in (_154_1005, [], t, _154_1004, d.FStar_Parser_AST.drange)))
in FStar_Syntax_Syntax.Sig_declare_typ (_154_1006))
in (

let env = (FStar_Parser_Env.push_sigelt env se)
in (env, (se)::[])))))
end
| FStar_Parser_AST.Exception (id, None) -> begin
(

let _63_2613 = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_lid env) FStar_Syntax_Const.exn_lid)
in (match (_63_2613) with
| (t, _63_2612) -> begin
(

let l = (FStar_Parser_Env.qualify env id)
in (

let se = FStar_Syntax_Syntax.Sig_datacon ((l, [], t, FStar_Syntax_Const.exn_lid, 0, (FStar_Syntax_Syntax.ExceptionConstructor)::[], (FStar_Syntax_Const.exn_lid)::[], d.FStar_Parser_AST.drange))
in (

let se' = FStar_Syntax_Syntax.Sig_bundle (((se)::[], (FStar_Syntax_Syntax.ExceptionConstructor)::[], (l)::[], d.FStar_Parser_AST.drange))
in (

let env = (FStar_Parser_Env.push_sigelt env se')
in (

let data_ops = (mk_data_projectors [] env ([], se))
in (

let discs = (mk_data_discriminators [] env FStar_Syntax_Const.exn_lid [] FStar_Syntax_Syntax.tun ((l)::[]))
in (

let env = (FStar_List.fold_left FStar_Parser_Env.push_sigelt env (FStar_List.append discs data_ops))
in (env, (FStar_List.append ((se')::discs) data_ops)))))))))
end))
end
| FStar_Parser_AST.Exception (id, Some (term)) -> begin
(

let t = (desugar_term env term)
in (

let t = (let _154_1011 = (let _154_1007 = (FStar_Syntax_Syntax.null_binder t)
in (_154_1007)::[])
in (let _154_1010 = (let _154_1009 = (let _154_1008 = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_lid env) FStar_Syntax_Const.exn_lid)
in (Prims.fst _154_1008))
in (FStar_All.pipe_left FStar_Syntax_Syntax.mk_Total _154_1009))
in (FStar_Syntax_Util.arrow _154_1011 _154_1010)))
in (

let l = (FStar_Parser_Env.qualify env id)
in (

let se = FStar_Syntax_Syntax.Sig_datacon ((l, [], t, FStar_Syntax_Const.exn_lid, 0, (FStar_Syntax_Syntax.ExceptionConstructor)::[], (FStar_Syntax_Const.exn_lid)::[], d.FStar_Parser_AST.drange))
in (

let se' = FStar_Syntax_Syntax.Sig_bundle (((se)::[], (FStar_Syntax_Syntax.ExceptionConstructor)::[], (l)::[], d.FStar_Parser_AST.drange))
in (

let env = (FStar_Parser_Env.push_sigelt env se')
in (

let data_ops = (mk_data_projectors [] env ([], se))
in (

let discs = (mk_data_discriminators [] env FStar_Syntax_Const.exn_lid [] FStar_Syntax_Syntax.tun ((l)::[]))
in (

let env = (FStar_List.fold_left FStar_Parser_Env.push_sigelt env (FStar_List.append discs data_ops))
in (env, (FStar_List.append ((se')::discs) data_ops)))))))))))
end
| FStar_Parser_AST.KindAbbrev (id, binders, k) -> begin
(

let _63_2642 = (desugar_binders env binders)
in (match (_63_2642) with
| (env_k, binders) -> begin
(

let k = (desugar_term env_k k)
in (

let name = (FStar_Parser_Env.qualify env id)
in (

let se = (mk_typ_abbrev name [] binders FStar_Syntax_Syntax.tun k ((name)::[]) [] d.FStar_Parser_AST.drange)
in (

let env = (FStar_Parser_Env.push_sigelt env se)
in (env, (se)::[])))))
end))
end
| FStar_Parser_AST.NewEffect (quals, FStar_Parser_AST.RedefineEffect (eff_name, eff_binders, defn)) -> begin
(

let env0 = env
in (

let _63_2658 = (desugar_binders env eff_binders)
in (match (_63_2658) with
| (env, binders) -> begin
(

let _63_2669 = (

let _63_2661 = (head_and_args defn)
in (match (_63_2661) with
| (head, args) -> begin
(

let ed = (match (head.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Name (l) -> begin
(FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_effect_defn env) l)
end
| _63_2665 -> begin
(let _154_1016 = (let _154_1015 = (let _154_1014 = (let _154_1013 = (let _154_1012 = (FStar_Parser_AST.term_to_string head)
in (Prims.strcat "Effect " _154_1012))
in (Prims.strcat _154_1013 " not found"))
in (_154_1014, d.FStar_Parser_AST.drange))
in FStar_Syntax_Syntax.Error (_154_1015))
in (Prims.raise _154_1016))
end)
in (let _154_1017 = (desugar_args env args)
in (ed, _154_1017)))
end))
in (match (_63_2669) with
| (ed, args) -> begin
(

let binders = (FStar_Syntax_Subst.close_binders binders)
in (

let sub = (fun _63_2675 -> (match (_63_2675) with
| (_63_2673, x) -> begin
(

let _63_2678 = (FStar_Syntax_Subst.open_term ed.FStar_Syntax_Syntax.binders x)
in (match (_63_2678) with
| (edb, x) -> begin
(

let _63_2679 = if ((FStar_List.length args) <> (FStar_List.length edb)) then begin
(Prims.raise (FStar_Syntax_Syntax.Error (("Unexpected number of arguments to effect constructor", defn.FStar_Parser_AST.range))))
end else begin
()
end
in (

let s = (FStar_Syntax_Util.subst_of_list edb args)
in (let _154_1021 = (let _154_1020 = (FStar_Syntax_Subst.subst s x)
in (FStar_Syntax_Subst.close binders _154_1020))
in ([], _154_1021))))
end))
end))
in (

let ed = (let _154_1035 = (FStar_List.map trans_qual quals)
in (let _154_1034 = (FStar_Parser_Env.qualify env0 eff_name)
in (let _154_1033 = (let _154_1022 = (sub ([], ed.FStar_Syntax_Syntax.signature))
in (Prims.snd _154_1022))
in (let _154_1032 = (sub ed.FStar_Syntax_Syntax.ret)
in (let _154_1031 = (sub ed.FStar_Syntax_Syntax.bind_wp)
in (let _154_1030 = (sub ed.FStar_Syntax_Syntax.if_then_else)
in (let _154_1029 = (sub ed.FStar_Syntax_Syntax.ite_wp)
in (let _154_1028 = (sub ed.FStar_Syntax_Syntax.stronger)
in (let _154_1027 = (sub ed.FStar_Syntax_Syntax.close_wp)
in (let _154_1026 = (sub ed.FStar_Syntax_Syntax.assert_p)
in (let _154_1025 = (sub ed.FStar_Syntax_Syntax.assume_p)
in (let _154_1024 = (sub ed.FStar_Syntax_Syntax.null_wp)
in (let _154_1023 = (sub ed.FStar_Syntax_Syntax.trivial)
in {FStar_Syntax_Syntax.qualifiers = _154_1035; FStar_Syntax_Syntax.mname = _154_1034; FStar_Syntax_Syntax.univs = []; FStar_Syntax_Syntax.binders = binders; FStar_Syntax_Syntax.signature = _154_1033; FStar_Syntax_Syntax.ret = _154_1032; FStar_Syntax_Syntax.bind_wp = _154_1031; FStar_Syntax_Syntax.if_then_else = _154_1030; FStar_Syntax_Syntax.ite_wp = _154_1029; FStar_Syntax_Syntax.stronger = _154_1028; FStar_Syntax_Syntax.close_wp = _154_1027; FStar_Syntax_Syntax.assert_p = _154_1026; FStar_Syntax_Syntax.assume_p = _154_1025; FStar_Syntax_Syntax.null_wp = _154_1024; FStar_Syntax_Syntax.trivial = _154_1023})))))))))))))
in (

let se = FStar_Syntax_Syntax.Sig_new_effect ((ed, d.FStar_Parser_AST.drange))
in (

let env = (FStar_Parser_Env.push_sigelt env0 se)
in (env, (se)::[]))))))
end))
end)))
end
| FStar_Parser_AST.NewEffectForFree (FStar_Parser_AST.RedefineEffect (_63_2686)) -> begin
(FStar_All.failwith "impossible")
end
| FStar_Parser_AST.NewEffectForFree (FStar_Parser_AST.DefineEffect (eff_name, eff_binders, eff_kind, eff_decls)) -> begin
(desugar_effect env d [] eff_name eff_binders eff_kind eff_decls (fun mname qualifiers binders eff_k lookup -> (

let dummy_tscheme = (let _154_1045 = (FStar_Syntax_Syntax.mk FStar_Syntax_Syntax.Tm_unknown None FStar_Range.dummyRange)
in ([], _154_1045))
in (let _154_1052 = (let _154_1051 = (let _154_1050 = (lookup "return")
in (let _154_1049 = (lookup "bind_wp")
in (let _154_1048 = (lookup "ite_wp")
in (let _154_1047 = (lookup "stronger")
in (let _154_1046 = (lookup "null_wp")
in {FStar_Syntax_Syntax.qualifiers = qualifiers; FStar_Syntax_Syntax.mname = mname; FStar_Syntax_Syntax.univs = []; FStar_Syntax_Syntax.binders = binders; FStar_Syntax_Syntax.signature = eff_k; FStar_Syntax_Syntax.ret = _154_1050; FStar_Syntax_Syntax.bind_wp = _154_1049; FStar_Syntax_Syntax.if_then_else = dummy_tscheme; FStar_Syntax_Syntax.ite_wp = _154_1048; FStar_Syntax_Syntax.stronger = _154_1047; FStar_Syntax_Syntax.close_wp = dummy_tscheme; FStar_Syntax_Syntax.assert_p = dummy_tscheme; FStar_Syntax_Syntax.assume_p = dummy_tscheme; FStar_Syntax_Syntax.null_wp = _154_1046; FStar_Syntax_Syntax.trivial = dummy_tscheme})))))
in (_154_1051, d.FStar_Parser_AST.drange))
in FStar_Syntax_Syntax.Sig_new_effect_for_free (_154_1052)))))
end
| FStar_Parser_AST.NewEffect (quals, FStar_Parser_AST.DefineEffect (eff_name, eff_binders, eff_kind, eff_decls)) -> begin
(desugar_effect env d quals eff_name eff_binders eff_kind eff_decls (fun mname qualifiers binders eff_k lookup -> (let _154_1073 = (let _154_1072 = (let _154_1071 = (lookup "return")
in (let _154_1070 = (lookup "bind_wp")
in (let _154_1069 = (lookup "if_then_else")
in (let _154_1068 = (lookup "ite_wp")
in (let _154_1067 = (lookup "stronger")
in (let _154_1066 = (lookup "close_wp")
in (let _154_1065 = (lookup "assert_p")
in (let _154_1064 = (lookup "assume_p")
in (let _154_1063 = (lookup "null_wp")
in (let _154_1062 = (lookup "trivial")
in {FStar_Syntax_Syntax.qualifiers = qualifiers; FStar_Syntax_Syntax.mname = mname; FStar_Syntax_Syntax.univs = []; FStar_Syntax_Syntax.binders = binders; FStar_Syntax_Syntax.signature = eff_k; FStar_Syntax_Syntax.ret = _154_1071; FStar_Syntax_Syntax.bind_wp = _154_1070; FStar_Syntax_Syntax.if_then_else = _154_1069; FStar_Syntax_Syntax.ite_wp = _154_1068; FStar_Syntax_Syntax.stronger = _154_1067; FStar_Syntax_Syntax.close_wp = _154_1066; FStar_Syntax_Syntax.assert_p = _154_1065; FStar_Syntax_Syntax.assume_p = _154_1064; FStar_Syntax_Syntax.null_wp = _154_1063; FStar_Syntax_Syntax.trivial = _154_1062}))))))))))
in (_154_1072, d.FStar_Parser_AST.drange))
in FStar_Syntax_Syntax.Sig_new_effect (_154_1073))))
end
| FStar_Parser_AST.SubEffect (l) -> begin
(

let lookup = (fun l -> (match ((FStar_Parser_Env.try_lookup_effect_name env l)) with
| None -> begin
(let _154_1080 = (let _154_1079 = (let _154_1078 = (let _154_1077 = (let _154_1076 = (FStar_Syntax_Print.lid_to_string l)
in (Prims.strcat "Effect name " _154_1076))
in (Prims.strcat _154_1077 " not found"))
in (_154_1078, d.FStar_Parser_AST.drange))
in FStar_Syntax_Syntax.Error (_154_1079))
in (Prims.raise _154_1080))
end
| Some (l) -> begin
l
end))
in (

let src = (lookup l.FStar_Parser_AST.msource)
in (

let dst = (lookup l.FStar_Parser_AST.mdest)
in (

let lift = (let _154_1081 = (desugar_term env l.FStar_Parser_AST.lift_op)
in ([], _154_1081))
in (

let se = FStar_Syntax_Syntax.Sig_sub_effect (({FStar_Syntax_Syntax.source = src; FStar_Syntax_Syntax.target = dst; FStar_Syntax_Syntax.lift = lift}, d.FStar_Parser_AST.drange))
in (env, (se)::[]))))))
end)))


let desugar_decls : FStar_Parser_Env.env  ->  FStar_Parser_AST.decl Prims.list  ->  (FStar_Parser_Env.env * FStar_Syntax_Syntax.sigelts) = (fun env decls -> (FStar_List.fold_left (fun _63_2731 d -> (match (_63_2731) with
| (env, sigelts) -> begin
(

let _63_2735 = (desugar_decl env d)
in (match (_63_2735) with
| (env, se) -> begin
(env, (FStar_List.append sigelts se))
end))
end)) (env, []) decls))


let open_prims_all : FStar_Parser_AST.decl Prims.list = ((FStar_Parser_AST.mk_decl (FStar_Parser_AST.Open (FStar_Syntax_Const.prims_lid)) FStar_Range.dummyRange))::((FStar_Parser_AST.mk_decl (FStar_Parser_AST.Open (FStar_Syntax_Const.all_lid)) FStar_Range.dummyRange))::[]


let desugar_modul_common : FStar_Syntax_Syntax.modul Prims.option  ->  FStar_Parser_Env.env  ->  FStar_Parser_AST.modul  ->  (env_t * FStar_Syntax_Syntax.modul * Prims.bool) = (fun curmod env m -> (

let env = (match (curmod) with
| None -> begin
env
end
| Some (prev_mod) -> begin
(FStar_Parser_Env.finish_module_or_interface env prev_mod)
end)
in (

let _63_2758 = (match (m) with
| FStar_Parser_AST.Interface (mname, decls, admitted) -> begin
(let _154_1094 = (FStar_Parser_Env.prepare_module_or_interface true admitted env mname)
in (_154_1094, mname, decls, true))
end
| FStar_Parser_AST.Module (mname, decls) -> begin
(let _154_1095 = (FStar_Parser_Env.prepare_module_or_interface false false env mname)
in (_154_1095, mname, decls, false))
end)
in (match (_63_2758) with
| ((env, pop_when_done), mname, decls, intf) -> begin
(

let _63_2761 = (desugar_decls env decls)
in (match (_63_2761) with
| (env, sigelts) -> begin
(

let modul = {FStar_Syntax_Syntax.name = mname; FStar_Syntax_Syntax.declarations = sigelts; FStar_Syntax_Syntax.exports = []; FStar_Syntax_Syntax.is_interface = intf}
in (env, modul, pop_when_done))
end))
end))))


let desugar_partial_modul : FStar_Syntax_Syntax.modul Prims.option  ->  FStar_Parser_Env.env  ->  FStar_Parser_AST.modul  ->  (FStar_Parser_Env.env * FStar_Syntax_Syntax.modul) = (fun curmod env m -> (

let m = if (FStar_Options.interactive_fsi ()) then begin
(match (m) with
| FStar_Parser_AST.Module (mname, decls) -> begin
FStar_Parser_AST.Interface ((mname, decls, true))
end
| FStar_Parser_AST.Interface (mname, _63_2772, _63_2774) -> begin
(FStar_All.failwith (Prims.strcat "Impossible: " mname.FStar_Ident.ident.FStar_Ident.idText))
end)
end else begin
m
end
in (

let _63_2782 = (desugar_modul_common curmod env m)
in (match (_63_2782) with
| (x, y, _63_2781) -> begin
(x, y)
end))))


let desugar_modul : FStar_Parser_Env.env  ->  FStar_Parser_AST.modul  ->  (env_t * FStar_Syntax_Syntax.modul) = (fun env m -> (

let _63_2788 = (desugar_modul_common None env m)
in (match (_63_2788) with
| (env, modul, pop_when_done) -> begin
(

let env = (FStar_Parser_Env.finish_module_or_interface env modul)
in (

let _63_2790 = if (FStar_Options.dump_module modul.FStar_Syntax_Syntax.name.FStar_Ident.str) then begin
(let _154_1106 = (FStar_Syntax_Print.modul_to_string modul)
in (FStar_Util.print1 "%s\n" _154_1106))
end else begin
()
end
in (let _154_1107 = if pop_when_done then begin
(FStar_Parser_Env.export_interface modul.FStar_Syntax_Syntax.name env)
end else begin
env
end
in (_154_1107, modul))))
end)))


let desugar_file : FStar_Parser_Env.env  ->  FStar_Parser_AST.file  ->  (FStar_Parser_Env.env * FStar_Syntax_Syntax.modul Prims.list) = (fun env f -> (

let _63_2803 = (FStar_List.fold_left (fun _63_2796 m -> (match (_63_2796) with
| (env, mods) -> begin
(

let _63_2800 = (desugar_modul env m)
in (match (_63_2800) with
| (env, m) -> begin
(env, (m)::mods)
end))
end)) (env, []) f)
in (match (_63_2803) with
| (env, mods) -> begin
(env, (FStar_List.rev mods))
end)))


let add_modul_to_env : FStar_Syntax_Syntax.modul  ->  FStar_Parser_Env.env  ->  FStar_Parser_Env.env = (fun m en -> (

let _63_2808 = (FStar_Parser_Env.prepare_module_or_interface false false en m.FStar_Syntax_Syntax.name)
in (match (_63_2808) with
| (en, pop_when_done) -> begin
(

let en = (FStar_List.fold_left FStar_Parser_Env.push_sigelt (

let _63_2809 = en
in {FStar_Parser_Env.curmodule = Some (m.FStar_Syntax_Syntax.name); FStar_Parser_Env.modules = _63_2809.FStar_Parser_Env.modules; FStar_Parser_Env.open_namespaces = _63_2809.FStar_Parser_Env.open_namespaces; FStar_Parser_Env.modul_abbrevs = _63_2809.FStar_Parser_Env.modul_abbrevs; FStar_Parser_Env.sigaccum = _63_2809.FStar_Parser_Env.sigaccum; FStar_Parser_Env.localbindings = _63_2809.FStar_Parser_Env.localbindings; FStar_Parser_Env.recbindings = _63_2809.FStar_Parser_Env.recbindings; FStar_Parser_Env.sigmap = _63_2809.FStar_Parser_Env.sigmap; FStar_Parser_Env.default_result_effect = _63_2809.FStar_Parser_Env.default_result_effect; FStar_Parser_Env.iface = _63_2809.FStar_Parser_Env.iface; FStar_Parser_Env.admitted_iface = _63_2809.FStar_Parser_Env.admitted_iface; FStar_Parser_Env.expect_typ = _63_2809.FStar_Parser_Env.expect_typ}) m.FStar_Syntax_Syntax.exports)
in (

let env = (FStar_Parser_Env.finish_module_or_interface en m)
in if pop_when_done then begin
(FStar_Parser_Env.export_interface m.FStar_Syntax_Syntax.name env)
end else begin
env
end))
end)))




