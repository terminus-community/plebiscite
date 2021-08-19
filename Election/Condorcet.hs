module Election.Condorcet where

import "base" Data.Function ((.), (&))
import "base" Data.Int (Int)
import "lens" Control.Lens (element, (.~))

vote :: [[Int]] -> Int -> Int -> [[Int]]
vote prefers voter votes = prefers & element voter . element votes .~ 1
