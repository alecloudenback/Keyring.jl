if Sys.iswindows()
    @testset "Windows specific tests" begin
        run(Cmd(["cmdkey", "/generic:server01", "/user:mikedan", "/pass:Kleo"]))
        c = get_credential("server01")
        @test c.target == "server01"
        @test c.username == "mikedan"
        @test c.secret == "Kleo"
    end
end