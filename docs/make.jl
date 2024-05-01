using Keyring
using Documenter

DocMeta.setdocmeta!(Keyring, :DocTestSetup, :(using Keyring); recursive=true)

makedocs(;
    modules=[Keyring],
    authors="Alec Loudenback <alecloudenback@gmail.com> and contributors",
    sitename="Keyring.jl",
    format=Documenter.HTML(;
        canonical="https://alecloudenback.github.io/Keyring.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/alecloudenback/Keyring.jl",
    devbranch="master",
)
