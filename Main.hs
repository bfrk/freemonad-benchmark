{-# LANGUAGE FlexibleContexts, RankNTypes #-}
module Main (main) where

import Base
import Computation
import qualified Free
import qualified Church
import qualified Codensity
import qualified NoRemorse
import Control.Monad
import qualified Control.Monad.State.Strict as MTL

import Criterion (bench, nf, bgroup, Benchmark)
import Criterion.Main (defaultMain)


n = 2^n2
n2 = 10

benchmarks
  :: (forall m . (Monad m, MonadFree F m) => Int -> m ())
  -> (Int -> MTL.State Int ())
  -> Int
  -> [Benchmark]
benchmarks computation mtlComputation n =
  [ bench "Free" $ nf (flip Free.run 0 . computation) n
  , bench "Free/lazy" $ nf (flip Free.runLazily 0 . computation) n
  , bench "Chruch" $ nf (flip Church.run 0 . computation) n
  , bench "Codensity" $ nf (flip Codensity.run 0 . computation) n
  , bench "NoRemorse" $ nf (flip NoRemorse.run 0 . computation) n
  , bench "MTL" $ nf (flip MTL.runState 0 . mtlComputation) n
  ]

main :: IO ()
main = defaultMain
  [ bgroup "Linear" $ benchmarks computation mtlComputation n
  , bgroup "Tree" $ benchmarks computation2 mtlComputation2 n2
  ]
