#light "off"
module TestSeq
open Prims

let rec print_seq : Prims.nat  ->  Prims.int FStar.Seq.seq  ->  Prims.unit = (fun ( i  :  Prims.nat ) ( s  :  Prims.int FStar.Seq.seq ) -> (match ((i = (FStar.Seq.length s))) with
| true -> begin
()
end
| uu____20 -> begin
(FStar.IO.print_string (Prims.string_of_int (FStar.Seq.index s i)));
(print_seq (i + (Prims.parse_int "1")) s);

end))


let main : Prims.unit = (print_seq (Prims.parse_int "0") (FStar.Seq.create (Prims.parse_int "100") (Prims.parse_int "0")))




