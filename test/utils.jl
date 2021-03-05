using MeshRefiner.Utils

@testset "center_point" begin
    @test center_point([[1.0], [2.0], [3.0]]) == [2.0]
    @test center_point([[1], [2], [3]]) == [2]
    @test center_point([[1,2], [2,3], [3,4]]) == [2, 3]
end
