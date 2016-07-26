#light "off"
module FStar.Seq
open Prims
type 'Aa seq =
| MkSeq of Prims.nat * (Prims.nat  ->  'Aa)


let ___MkSeq___length = (fun ( projectee  :  'Aa seq ) -> (match ((projectee)) with
| MkSeq (length, contents) -> begin
length
end))


let ___MkSeq___contents = (fun ( projectee  :  'Aa seq ) -> (match ((projectee)) with
| MkSeq (length, contents) -> begin
contents
end))


let length = (fun ( s  :  'Aa seq ) -> (___MkSeq___length s))


let index = (fun ( s  :  'Aa seq ) ( i  :  Prims.nat ) -> ((___MkSeq___contents s) i))


let create = (fun ( len  :  Prims.nat ) ( v  :  'Aa ) -> MkSeq (len, (fun ( i  :  Prims.nat ) -> v)))


let exFalso0 = ((fun ( n  :  Prims.nat ) -> ()))


let createEmpty = (fun ( uu____129  :  Prims.unit ) -> MkSeq ((Prims.parse_int "0"), (fun ( i  :  Prims.nat ) -> (exFalso0 i))))


let upd = (fun ( s  :  'Aa seq ) ( n  :  Prims.nat ) ( v  :  'Aa ) -> MkSeq ((length s), (fun ( i  :  Prims.nat ) -> (match ((i = n)) with
| true -> begin
v
end
| uu____179 -> begin
(index s i)
end))))


let append = (fun ( s1  :  'Aa seq ) ( s2  :  'Aa seq ) -> MkSeq (((length s1) + (length s2)), (fun ( x  :  Prims.nat ) -> (match ((x < (length s1))) with
| true -> begin
(index s1 x)
end
| uu____214 -> begin
(index s2 (x - (length s1)))
end))))


let op_At_Bar = (fun ( s1  :  'Aa seq ) ( s2  :  'Aa seq ) -> (append s1 s2))


let slice = (fun ( s  :  'Aa seq ) ( i  :  Prims.nat ) ( j  :  Prims.nat ) -> MkSeq ((j - i), (fun ( x  :  Prims.nat ) -> (index s (x + i)))))


let lemma_create_len = (fun ( n  :  Prims.nat ) ( i  :  'Aa ) -> ())


let lemma_len_upd = (fun ( n  :  Prims.nat ) ( v  :  'Aa ) ( s  :  'Aa seq ) -> ())


let lemma_len_append = (fun ( s1  :  'Aa seq ) ( s2  :  'Aa seq ) -> ())


let lemma_len_slice = (fun ( s  :  'Aa seq ) ( i  :  Prims.nat ) ( j  :  Prims.nat ) -> ())


let lemma_index_create = (fun ( n  :  Prims.nat ) ( v  :  'Aa ) ( i  :  Prims.nat ) -> ())


let lemma_index_upd1 = (fun ( n  :  'Aa seq ) ( v  :  Prims.nat ) ( s  :  'Aa ) -> ())


let lemma_index_upd2 = (fun ( n  :  'Aa seq ) ( v  :  Prims.nat ) ( s  :  'Aa ) ( i  :  Prims.nat ) -> ())


let lemma_index_app1 = (fun ( s1  :  'Aa seq ) ( s2  :  'Aa seq ) ( i  :  Prims.nat ) -> ())


let lemma_index_app2 = (fun ( s1  :  'Aa seq ) ( s2  :  'Aa seq ) ( i  :  Prims.nat ) -> ())


let lemma_index_slice = (fun ( s  :  'Aa seq ) ( i  :  Prims.nat ) ( j  :  Prims.nat ) ( k  :  Prims.nat ) -> ())





let rec eq_i = (fun ( s1  :  'Aa seq ) ( s2  :  'Aa seq ) ( i  :  Prims.nat ) -> (match ((i = (length s1))) with
| true -> begin
true
end
| uu____596 -> begin
(match (((index s1 i) = (index s2 i))) with
| true -> begin
(eq_i s1 s2 (i + (Prims.parse_int "1")))
end
| uu____610 -> begin
false
end)
end))


let eq = (fun ( s1  :  'Aa seq ) ( s2  :  'Aa seq ) -> (match (((length s1) = (length s2))) with
| true -> begin
(eq_i s1 s2 (Prims.parse_int "0"))
end
| uu____642 -> begin
false
end))


let lemma_eq_intro = (fun ( s1  :  'Aa seq ) ( s2  :  'Aa seq ) -> ())


let lemma_eq_refl = (fun ( s1  :  'Aa seq ) ( s2  :  'Aa seq ) -> ())


let lemma_eq_elim = (fun ( s1  :  'Aa seq ) ( s2  :  'Aa seq ) -> ())




