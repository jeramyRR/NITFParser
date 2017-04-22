defmodule NitfParser.Parser2 do
  alias NitfParser.Nitf

  @moduledoc """
  NITF files are defined via a dynamic binary format.
  The following constants define the base binary sizes of most of the
  nitf header sections.

  @header_sz starts with a + 9 for the fhdr and fver size.
  """
  @header_sz        363

  def parse(file) do
    nitf_struct = case File.open(file, [:read]) do
      {:ok, io_device} ->
        { %Nitf{}, IO.binread(io_device, @header_sz) }
        |> parse_header
        |> get_image_segment_header_bits(io_device)
        |> parse_image_segments
      {:error, reason} ->
        raise "Unable to open file due to #{reason}"
    end

    File.close(file)
    nitf_struct
  end


  def parse_header({nitf_struct, bits}) do
    << "NITF",
      fver    :: binary-size(5),  clevel  :: binary-size(2),
      stype   :: binary-size(4),  ostaid  :: binary-size(8), 0x20, 0x20,
      fdt     :: binary-size(14), ftitle  :: binary-size(80),
      fclass  :: binary-size(1),  fsclsy  :: binary-size(2),
      fscode  :: binary-size(11), fsctlh  :: binary-size(2),
      fsrel   :: binary-size(20), fsdctp  :: binary-size(2),
      fsdcdt  :: binary-size(8),  fsdcxm  :: binary-size(4),
      fsdg    :: binary-size(1),  fsdgdt  :: binary-size(8),
      fscltx  :: binary-size(43), fscatp  :: binary-size(1),
      fscaut  :: binary-size(40), fscrsn  :: binary-size(1),
      fssrdt  :: binary-size(8),  fsctln  :: binary-size(15),
      fscop   :: binary-size(5),  fscpys  :: binary-size(5),
      encryp  :: binary-size(1),  fbkgc   :: binary-size(3),
      oname   :: binary-size(24), ophone  :: binary-size(18),
      fl      :: binary-size(12), hl      :: binary-size(6),
      numi    :: binary-size(3),  _rest :: binary >> = bits

     %Nitf{
      nitf_struct |
      fver: fver, clevel: clevel, stype: stype, ostaid: ostaid,
      fdt: fdt, ftitle: ftitle, fclass: fclass, fsclsy: fsclsy,
      fscode: fscode, fsctlh: fsctlh, fsrel: fsrel, fsdctp: fsdctp,
      fsdcdt: fsdcdt, fsdcxm: fsdcxm, fsdg: fsdg, fsdgdt: fsdgdt,
      fscltx: fscltx, fscatp: fscatp, fscaut: fscaut, fscrsn: fscrsn,
      fssrdt: fssrdt, fsctln: fsctln, fscop: fscop, fscpys: fscpys,
      encryp: encryp, fbkgc: fbkgc, oname: oname, ophone: ophone,
      fl: fl, hl: hl, numi: numi
    }

    end

    defp get_image_segment_header_bits(%{ hl: hl } = nitf_struct, io_device) do
      header_remaining_size = String.to_integer(hl) - @header_sz
      { nitf_struct, IO.binread(io_device, header_remaining_size)}
    end

    @doc """
     Using the number of image segments (numi), this function will
     recursively extract the subheader_length and segment_length for
     each image segment contained within the bits provided

     ## Examples:

     iex> NitfParser.Parser2.parse_image_segments({ %NitfParser.Nitf{ numi: "001"}, "0004990001048576" })
     %NitfParser.Nitf{ numi: "001", img_segs: [ [ LISH001: "000499", LI001: "0001048576" ] ]}

    """
    def parse_image_segments({ %Nitf{numi: numi} = nitf_struct, bits}) do
      num_image_segments = String.to_integer(numi)
      image_segments = parse_image_segments(bits, [], num_image_segments)
      %Nitf{ nitf_struct | img_segs: image_segments }
    end

    defp parse_image_segments(_bits, acc, 0), do: acc
    defp parse_image_segments(bits, acc, counter) do
      << subh_len :: binary-size(6), seg_len :: binary-size(10), rest :: binary >> = bits
      lish = "LISH00" <> Integer.to_string(counter) |> String.to_atom
      li = "LI00" <> Integer.to_string(counter) |> String.to_atom
      parse_image_segments(rest, [ [{lish, subh_len}, {li, seg_len}] | acc], counter - 1)
    end

end
