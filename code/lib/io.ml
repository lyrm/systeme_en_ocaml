open Unix

type in_channel = {
  in_buffer : Bytes.t;
  in_fd : Unix.file_descr;
  mutable in_pos : int;
  mutable in_end : int;
}

exception End_of_file

type out_channel = {
  out_buffer : Bytes.t;
  out_fd : Unix.file_descr;
  mutable out_pos : int;
}

let buffer_size = 8192

let open_in filename =
  {
    in_buffer = Bytes.create buffer_size;
    in_fd = openfile filename [ O_RDONLY ] 0;
    in_pos = 0;
    in_end = 0;
  }

let input_char chan =
  if chan.in_pos < chan.in_end then (
    let c = Bytes.get chan.in_buffer chan.in_pos in
    chan.in_pos <- chan.in_pos + 1;
    c)
  else
    match read chan.in_fd chan.in_buffer 0 buffer_size with
    | 0 -> raise End_of_file
    | r ->
        chan.in_end <- r;
        chan.in_pos <- 1;
        Bytes.get chan.in_buffer 0

let close_in chan = close chan.in_fd

let open_out filename =
  {
    out_buffer = Bytes.create 8192;
    out_fd = openfile filename [ O_WRONLY; O_TRUNC; O_CREAT ] 0o666;
    out_pos = 0;
  }

let output_char chan c =
  if chan.out_pos < Bytes.length chan.out_buffer then (
    chan.out_buffer.[chan.out_pos] <- c;
    chan.out_pos <- chan.out_pos + 1)
  else (
    ignore (write chan.out_fd chan.out_buffer 0 chan.out_pos);
    chan.out_buffer.[0] <- c;
    chan.out_pos <- 1)

let close_out chan =
  ignore (write chan.out_fd chan.out_buffer 0 chan.out_pos);
  close chan.out_fd

let output_string chan s =
  let avail = Bytes.length chan.out_buffer - chan.out_pos in
  let s = Bytes.of_string s in
  if Bytes.length s <= avail then (
    Bytes.blit s 0 chan.out_buffer chan.out_pos (Bytes.length s);
    chan.out_pos <- chan.out_pos + Bytes.length s)
  else if chan.out_pos = 0 then ignore (write chan.out_fd s 0 (Bytes.length s))
  else (
    Bytes.blit s 0 chan.out_buffer chan.out_pos avail;
    let out_buffer_size = Bytes.length chan.out_buffer in
    ignore (write chan.out_fd chan.out_buffer 0 out_buffer_size);
    let remaining = Bytes.length s - avail in
    if remaining < out_buffer_size then (
      Bytes.blit s avail chan.out_buffer 0 remaining;
      chan.out_pos <- remaining)
    else (
      ignore (write chan.out_fd s avail remaining);
      chan.out_pos <- 0))
