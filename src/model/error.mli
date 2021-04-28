type full_location_payload = Odoc_parser.Error.t = {
  location : Location_.span;
  message : string;
}

type filename_only_payload = { file : string; message : string }

type t =
  [ `With_full_location of Odoc_parser.Error.t
  | `With_filename_only of filename_only_payload ]

val make :
  ?suggestion:string ->
  ('a, Format.formatter, unit, Location_.span -> t) format4 ->
  'a

val filename_only :
  ?suggestion:string -> ('a, Format.formatter, unit, string -> t) format4 -> 'a

val to_string : t -> string

val raise_exception : t -> _

val to_exception : ('a, t) Result.result -> 'a

val catch : (unit -> 'a) -> ('a, t) Result.result

type warning = {
  w : t;
  non_fatal : bool;
      (** If [true], the warning won't be made fatal in [warn_error] mode. *)
}

type 'a with_warnings = { value : 'a; warnings : warning list }

val raise_warning : ?non_fatal:bool -> t -> unit
(** Raise a warning that need to be caught with [catch_warnings]. [non_fatal] is
    [false] by default. *)

val raise_warnings : 'a with_warnings -> 'a
(** Accumulate warnings into a global variable. See [catch_warnings]. *)

val catch_warnings : (unit -> 'a) -> 'a with_warnings
(** Catch warnings accumulated by [raise_warning]. Safe to nest. *)

type 'a with_errors_and_warnings = ('a, t) Result.result with_warnings
(** Subtype of [with_warnings]. *)

val catch_errors_and_warnings : (unit -> 'a) -> 'a with_errors_and_warnings
(** Combination of [catch] and [catch_warnings]. *)

val handle_warnings :
  warn_error:bool -> 'a with_warnings -> ('a, [> `Msg of string ]) Result.result
(** Print warnings to stderr. If [warn_error] is [true] and there was warnings,
    returns an [Error]. *)

val handle_errors_and_warnings :
  warn_error:bool ->
  'a with_errors_and_warnings ->
  ('a, [> `Msg of string ]) Result.result
(** Like [handle_warnings] but works on the output of
    [catch_errors_and_warnings]. Error case is converted into a [`Msg]. *)

val t_of_parser_t : Odoc_parser.Error.t -> t
(** Convert a parsing error into a [t]. *)

val raise_parser_warnings : 'a Odoc_parser.Error.with_warnings -> 'a
(** Like {!raise_warnings} but handle parsing errors. *)
