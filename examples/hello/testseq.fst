module TestSeq
open FStar
open FStar.IO

val print_seq : i:nat -> s:Seq.seq int {i <= Seq.length s} -> unit
let rec print_seq i s =
  if i = Seq.length s then ()
  else (print_string (string_of_int (Seq.index s i));
        print_seq (i + 1) s)

let main =
  print_seq 0 (Seq.create 100 0)
