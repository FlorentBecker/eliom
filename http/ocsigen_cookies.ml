(* Ocsigen
 * Copyright (C) 2010 Vincent Balat
 * Laboratoire PPS - CNRS Université Paris Diderot
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, with linking exception;
 * either version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)

type url_path = string list


module Cookies =
  Map.Make(struct type t = url_path let compare = compare end)

type cookie =
  | OSet of float option * string * bool
  | OUnset

type cookieset = cookie Ocsigen_lib.String_Table.t Cookies.t

let empty_cookieset = Cookies.empty

let add_cookie path n v t =
  let ct =
    try Cookies.find path t
    with Not_found -> Ocsigen_lib.String_Table.empty
  in
  (* We replace the old value if it exists *)
  Cookies.add path (Ocsigen_lib.String_Table.add n v ct) t

let remove_cookie path n t =
  try
    let ct = Cookies.find path t in
    let newct = Ocsigen_lib.String_Table.remove n ct in
    if Ocsigen_lib.String_Table.is_empty newct
    then Cookies.remove path t
    else (* We replace the old value *) Cookies.add path newct t
  with Not_found -> t

(* [add_cookies newcookies oldcookies] adds the cookies from [newcookies]
   to [oldcookies]. If cookies are already bound in oldcookies,
   the previous binding disappear. *)
let add_cookies newcookies oldcookies =
  Cookies.fold
    (fun path ct t ->
      Ocsigen_lib.String_Table.fold
        (fun n v beg ->
          match v with
          | OSet (expo, v, secure) ->
              add_cookie path n (OSet (expo, v, secure)) beg
          | OUnset ->
              add_cookie path n OUnset beg
        )
        ct
        t
    )
    newcookies
    oldcookies

