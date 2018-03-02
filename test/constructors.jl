module TestConstructors
    using Compat, Compat.Test, DataFrames
    using DataFrames: Index
    const ≅ = isequal

    #
    # DataFrame
    #

    df = DataFrame()
    @test df.columns == Any[]
    @test df.colindex == Index()

    df = DataFrame(Any[CategoricalVector{Union{Float64, Missing}}(zeros(3)),
                       CategoricalVector{Union{Float64, Missing}}(ones(3))],
                   Index([:x1, :x2]))
    @test size(df, 1) == 3
    @test size(df, 2) == 2

    @test df == DataFrame(Any[CategoricalVector{Union{Float64, Missing}}(zeros(3)),
                              CategoricalVector{Union{Float64, Missing}}(ones(3))])
    @test df == DataFrame(x1 = Union{Int, Missing}[0.0, 0.0, 0.0],
                          x2 = Union{Int, Missing}[1.0, 1.0, 1.0])

    df2 = convert(DataFrame, Union{Float64, Missing}[0.0 1.0;
                                                  0.0 1.0;
                                                  0.0 1.0])
    names!(df2, [:x1, :x2])
    @test df[:x1] == df2[:x1]
    @test df[:x2] == df2[:x2]

    df2 = DataFrame([0.0 1.0;
                     0.0 1.0;
                     0.0 1.0])
    names!(df2, [:x1, :x2])
    @test df[:x1] == df2[:x1]
    @test df[:x2] == df2[:x2]

    df2 = DataFrame([0.0 1.0;
                     0.0 1.0;
                     0.0 1.0], [:a, :b])
    names!(df2, [:a, :b])
    @test df[:x1] == df2[:a]
    @test df[:x2] == df2[:b]

    @test df == DataFrame(x1 = Union{Float64, Missing}[0.0, 0.0, 0.0],
                          x2 = Union{Float64, Missing}[1.0, 1.0, 1.0])
    @test df == DataFrame(x1 = Union{Float64, Missing}[0.0, 0.0, 0.0],
                          x2 = Union{Float64, Missing}[1.0, 1.0, 1.0],
                          x3 = Union{Float64, Missing}[2.0, 2.0, 2.0])[[:x1, :x2]]

    df = DataFrame(Union{Int, Missing}, 2, 2)
    @test size(df) == (2, 2)
    @test eltypes(df) == [Union{Int, Missing}, Union{Int, Missing}]

    df = DataFrame([Union{Int, Missing}, Union{Float64, Missing}], [:x1, :x2], 2)
    @test size(df) == (2, 2)
    @test eltypes(df) == [Union{Int, Missing}, Union{Float64, Missing}]

    @test df ≅ DataFrame([Union{Int, Missing}, Union{Float64, Missing}], 2)

    @test_throws BoundsError SubDataFrame(DataFrame(A=1), 0)
    @test_throws BoundsError SubDataFrame(DataFrame(A=1), 0)
    @test SubDataFrame(DataFrame(A=1), 1) == DataFrame(A=1)
    @test SubDataFrame(DataFrame(A=1:10), 1:4) == DataFrame(A=1:4)
    @test view(SubDataFrame(DataFrame(A=1:10), 1:4), 2) == DataFrame(A=2)
    @test view(SubDataFrame(DataFrame(A=1:10), 1:4), [true, true, false, false]) == DataFrame(A=1:2)

    @test DataFrame(a=1, b=1:2) == DataFrame(a=[1,1], b=[1,2])

    @testset "pair constructor" begin
        dfa = DataFrame(:x1 => zeros(3), :x2 => ones(3))
        @test size(dfa, 1) == 3
        @test size(dfa, 2) == 2
        @test isequal(dfa, DataFrame(x1 = [0.0, 0.0, 0.0], x2 = [1.0, 1.0, 1.0]))

        dfa = DataFrame(:type => [], :begin => [])
        @test names(dfa) == [:type, :begin]
    end

    @testset "associative" begin
        dfa = DataFrame(Dict(:A => 1:3, :B => 4:6))
        @test dfa == DataFrame(A = 1:3, B = 4:6)
        @test eltypes(dfa) == [Int, Int]
    end

    @testset "recyclers" begin
        @test DataFrame(a = 1:5, b = 1) == DataFrame(a = collect(1:5), b = fill(1, 5))
        @test DataFrame(a = 1, b = 1:5) == DataFrame(a = fill(1, 5), b = collect(1:5))
    end

    @testset "constructor errors" begin
        @test_throws DimensionMismatch DataFrame(a=1, b=[])
        @test_throws DimensionMismatch DataFrame(Any[collect(1:10)], DataFrames.Index([:A, :B]))
        @test_throws DimensionMismatch DataFrame(A = rand(2,2))
        @test_throws DimensionMismatch DataFrame(A = rand(2,1))
    end

    @testset "column types" begin
        dfa = DataFrame(A = 1:3, B = 2:4, C = 3:5)
        answer = [Array{Int,1}, Array{Int,1}, Array{Int,1}]
        @test map(typeof, dfa.columns) == answer
        dfa[:D] = [4, 5, missing]
        push!(answer, Vector{Union{Int, Missing}})
        @test map(typeof, dfa.columns) == answer
        dfa[:E] = 'c'
        push!(answer, Vector{Char})
        @test map(typeof, dfa.columns) == answer
    end

    @testset "categorical constructor" begin
        dfa = DataFrame([Int, String], [:a, :b], [false, true], 3)
        @test !(dfa[:a] isa CategoricalVector)
        @test dfa[:b] isa CategoricalVector
        @test_throws DimensionMismatch DataFrame([Int, String], [:a, :b], [true], 3)
    end
end
