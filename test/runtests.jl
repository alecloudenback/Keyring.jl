using Keyring
using Test

@testset "Keyring.jl defaults" begin
    # this should work on any system
    set_credential("test", "un", "pw")

    c = get_credential("test")

    @test c.target == "test"
    @test c.username == "un"
    @test c.secret == "pw"

    # non-existent credential

    c = get_credential("non-existent")
    # @test c == Some(nothing)


end

include("Windows.jl")
