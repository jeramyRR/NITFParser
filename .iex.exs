files = File.ls!("/Users/jeramy/Documents/nitfs/") |> Enum.filter(&String.contains?(String.downcase(&1), ".ntf")) |> Enum.map(fn file -> "/Users/jeramy/Documents/nitfs/" <> file end)
