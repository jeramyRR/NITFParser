defmodule NitfParser.Nitf do
  defstruct fhdr: "NITF", fver: nil, clevel: nil, stype: nil,
            ostaid: nil, fdt: nil, ftitle: nil, fclass: nil,
            fsclsy: nil, fscode: nil, fsctlh: nil, fsrel: nil,
            fsdctp: nil, fsdcdt: nil, fsdcxm: nil, fsdg: nil,
            fsdgdt: nil, fscltx: nil, fscatp: nil, fscaut: nil,
            fscrsn: nil, fssrdt: nil, fsctln: nil, fscop: nil,
            fscpys: nil, encryp: nil, fbkgc: nil, oname: nil,
            ophone: nil, fl: nil, hl: nil, numi: nil, img_segs: []


  def update(nitf_struct, key, value) do
    Map.put(nitf_struct, key, value)
  end

  defimpl String.Chars, for: NitfParser.Nitf do
    def to_string(%NitfParser.Nitf{}), do: ""
    def to_string(nitf), do: inspect(nitf)
  end
end
