using Keyring
using Test

@testset "Keyring.jl defaults" begin
    # this should work on any system
    set_credential("test", "un", "pw")

    c = get_credential("test")

    @test c.target == "test"
    @test c.username == "un"
    @test c.secret == "pw"


end

include("Windows.jl")
