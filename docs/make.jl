using Keychain
using Documenter

DocMeta.setdocmeta!(Keychain, :DocTestSetup, :(using Keychain); recursive=true)

makedocs(;
    modules=[Keychain],
    authors="Alec Loudenback <alecloudenback@gmail.com> and contributors",
    sitename="Keychain.jl",
    format=Documenter.HTML(;
        canonical="https://alecloudenback.github.io/Keychain.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/alecloudenback/Keychain.jl",
    devbranch="master",
)
