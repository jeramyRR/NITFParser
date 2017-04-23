defmodule NitfParser.Parser do
  alias NitfParser.Nitf

  @moduledoc """
    NITF files are defined via a dynamic binary format.
    The following constants define the base binary szs of most of the nitf header sections.

    @header_sz starts with a + 9 for the fhdr and fver size.
  """

  @header_sz        363


  @clevel_sz        2
  @stype_sz         4
  @ostaid_sz        8 # count this as 10 (there are 2 BCS)
  @fdt_sz           14
  @ftitle_sz        80
  @fclass_sz        1
  @fsclsy_sz        2
  @fscode_sz        11
  @fsctlh_sz        2
  @fsrel_sz         20
  @fsdctp_sz        2
  @fsdcdt_sz        8
  @fsdcxm_sz        4
  @fsdg_sz          1
  @fsdgdt_sz        8
  @fscltx_sz        43
  @fscatp_sz        1
  @fscaut_sz        40
  @fscrsn_sz        1
  @fssrdt_sz        8
  @fsctln_sz        15
  @fscop_sz         5
  @fscpys_sz        5
  @encryp_sz        1
  @fbkgc_sz         3
  @oname_sz         24
  @ophone_sz        18
  @fl_sz            12
  @hl_sz            6

  @doc """
    @bcs is the hex for blank space
  """
  @bcs              0x20


  def parse(file) do
    nitf_struct = case File.open(file, [:read]) do
      {:ok, io_device} ->
        parse_header({%Nitf{}, IO.binread(io_device, @header_sz)})
      {:error, reason} ->
        raise "Unable to open file due to #{reason}"
    end

    File.close(file)
    nitf_struct
  end

  def parse_header({nitf_struct, bits}) do
    {final_struct, _ } =
      {nitf_struct, bits}
      |> parse_fdhr
      |> parse_fver
      |> parse_clevel
      |> parse_stype
      |> parse_ostaid
      |> parse_fdt
      |> parse_ftitle
      |> parse_fclass
      |> parse_fsclsy
      |> parse_fscode
      |> parse_fsctlh
      |> parse_fsrel
      |> parse_fsdctp
      |> parse_fsdcdt
      |> parse_fsdcxm
      |> parse_fsdg
      |> parse_fsdgdt
      |> parse_fscltx
      |> parse_fscatp
      |> parse_fscaut
      |> parse_fscrsn
      |> parse_fssrdt
      |> parse_fsctln
      |> parse_fscop
      |> parse_fscpys
      |> parse_encryp
      |> parse_fbkgc
      |> parse_oname
      |> parse_ophone
      |> parse_fl
      |> parse_hl

   final_struct
  end


  def parse_fdhr({nitf_struct, << "NITF", rest :: binary >>}), do: {nitf_struct, rest}
  def parse_fdhr({_, _}), do: raise "File not recognized as a NITF file"

  def parse_fver({nitf_struct, << "02.10", rest :: binary>>}), do: { %Nitf{nitf_struct | fver: "02.10"}, rest}

  def parse_clevel({nitf_struct, bits}), do: parse_binary(nitf_struct, bits, :clevel, @clevel_sz)
  defp parse_stype({nitf_struct,  bits}), do: parse_binary(nitf_struct, bits, :stype, @stype_sz)

  defp parse_ostaid({nitf_struct, << ostaid :: binary-size(@ostaid_sz), @bcs, @bcs, rest :: binary >>}) do
    new_struct = %Nitf{nitf_struct | ostaid: ostaid}
    { new_struct, rest }
  end

  defp parse_fdt({nitf_struct,    bits}), do: parse_binary(nitf_struct, bits, :fdt, @fdt_sz)
  defp parse_ftitle({nitf_struct, bits}), do: parse_binary(nitf_struct, bits, :ftitle, @ftitle_sz)
  defp parse_fclass({nitf_struct, bits}), do: parse_binary(nitf_struct, bits, :fclass, @fclass_sz)
  defp parse_fsclsy({nitf_struct, bits}), do: parse_binary(nitf_struct, bits, :fsclsy, @fsclsy_sz)
  defp parse_fscode({nitf_struct, bits}), do: parse_binary(nitf_struct, bits, :fscode, @fscode_sz)
  defp parse_fsctlh({nitf_struct, bits}), do: parse_binary(nitf_struct, bits, :fsctlh, @fsctlh_sz)
  defp parse_fsrel({nitf_struct,  bits}), do: parse_binary(nitf_struct, bits, :fsrel, @fsrel_sz)
  defp parse_fsdctp({nitf_struct, bits}), do: parse_binary(nitf_struct, bits, :fsdctp, @fsdctp_sz)
  defp parse_fsdcdt({nitf_struct, bits}), do: parse_binary(nitf_struct, bits, :fsdcdt, @fsdcdt_sz)
  defp parse_fsdcxm({nitf_struct, bits}), do: parse_binary(nitf_struct, bits, :fsdcxm, @fsdcxm_sz)
  defp parse_fsdg({nitf_struct,   bits}), do: parse_binary(nitf_struct, bits, :fsdg, @fsdg_sz)
  defp parse_fsdgdt({nitf_struct, bits}), do: parse_binary(nitf_struct, bits, :fsdgdt, @fsdgdt_sz)
  defp parse_fscltx({nitf_struct, bits}), do: parse_binary(nitf_struct, bits, :fscltx, @fscltx_sz)
  defp parse_fscatp({nitf_struct, bits}), do: parse_binary(nitf_struct, bits, :fscatp, @fscatp_sz)
  defp parse_fscaut({nitf_struct, bits}), do: parse_binary(nitf_struct, bits, :fscaut, @fscaut_sz)
  defp parse_fscrsn({nitf_struct, bits}), do: parse_binary(nitf_struct, bits, :fscrsn, @fscrsn_sz)
  defp parse_fssrdt({nitf_struct, bits}), do: parse_binary(nitf_struct, bits, :fssrdt, @fssrdt_sz)
  defp parse_fsctln({nitf_struct, bits}), do: parse_binary(nitf_struct, bits, :fsctln, @fsctln_sz)
  defp parse_fscop({nitf_struct, bits}) , do: parse_binary(nitf_struct, bits, :fscop, @fscop_sz)
  defp parse_fscpys({nitf_struct, bits}), do: parse_binary(nitf_struct, bits, :fscpys, @fscpys_sz)
  defp parse_encryp({nitf_struct, bits}), do: parse_binary(nitf_struct, bits, :encryp, @encryp_sz)
  defp parse_fbkgc({nitf_struct, bits}) , do: parse_binary(nitf_struct, bits, :fbkgc, @fbkgc_sz)
  defp parse_oname({nitf_struct, bits}) , do: parse_binary(nitf_struct, bits, :oname, @oname_sz)
  defp parse_ophone({nitf_struct, bits}), do: parse_binary(nitf_struct, bits, :ophone, @ophone_sz)
  defp parse_fl({nitf_struct, bits})    , do: parse_binary(nitf_struct, bits, :fl, @fl_sz)
  defp parse_hl({nitf_struct, bits})    , do: parse_binary(nitf_struct, bits, :hl, @hl_sz)

  defp parse_binary(nitf_struct, bits, key, size) do
    << value :: binary-size(size), rest :: binary >> = bits
    new_struct = Map.put(nitf_struct, key, value)
    {new_struct, rest}
  end

end
