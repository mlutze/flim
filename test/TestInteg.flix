namespace Flim/TestInteg {
    use Flim/TestUtils.mkIntegTest;

    /// @test
    /// pub def testCountToTen(): Bool & Impure = mkIntegTest(
    ///     "test/resources/count-to-ten.slim",
    ///     Nil,
    ///     1 :: 2 :: 3 :: 4 :: 5 :: 6 :: 7 :: 8 :: 9 :: 10 :: Nil
    /// )

    @test
    pub def testWriteLarger(): Bool & Impure = mkIntegTest(
        "test/resources/write-larger.slim",
        1 :: 2 :: Nil,
        2 :: Nil
    )
}