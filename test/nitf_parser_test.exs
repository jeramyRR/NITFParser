defmodule NitfParser.ParserTest do
  use ExUnit.Case
  doctest NitfParser.Parser

  alias NitfParser.Parser
  alias NitfParser.Nitf

  @nitf_path "/Users/jeramy/Downloads/i_3001a.ntf"
  @not_nitf_path "/Users/jeramy/Downloads/2500C.pdf"

  setup_all do
    nitf_struct = Parser.parse(@nitf_path)
    {:ok, [nitf_struct: nitf_struct]}
  end

  test "the first four characters of a nitf file are NITF", %{nitf_struct: nitf_struct} do
    %Nitf{fhdr: nitf} = nitf_struct
    assert nitf == "NITF"
  end


  test "the next five characters after the profile_name are the version", %{nitf_struct: nitf_struct} do
    %Nitf{fver: version} = nitf_struct
    assert version == "02.10"
  end

  test "the next two characters after the file_version are the CLEVEL", %{nitf_struct: nitf_struct}  do
    %Nitf{clevel: clevel} = nitf_struct
    assert clevel == "03"
  end

  test "stype shall be BF01", %{nitf_struct: nitf_struct} do
    %Nitf{stype: stype} = nitf_struct
    assert stype == "BF01"
  end

  test "osaid shall be i_3001a", %{nitf_struct: nitf_struct} do
    %Nitf{ostaid: ostaid} = nitf_struct
    assert ostaid == "i_3001a "
  end


  test "a non-nitf file shall raise an error" do
    assert_raise(RuntimeError,
                "File not recognized as a NITF file",
                fn -> Parser.parse(@not_nitf_path) end)
  end


end
