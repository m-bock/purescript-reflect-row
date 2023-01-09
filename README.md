# purescript-reflect-row
A small util that reflects a `Row k` to an `Array (Tuple String a)` as long
there is a `Reflectable k a` instance.

## Example

These imports are needed for the example code:

```hs
module Test.GenReadme where

import Prelude

import Data.Generic.Rep (class Generic)
import Data.Reflectable (class Reflectable)
import Data.Show.Generic (genericShow)
import Data.Tuple (Tuple)
import Reflection.Row (class ReflectRow, reflectRow)
import Type.Proxy (Proxy(..))
```
Consider the following definition of a type level tree:
```hs
foreign import data Tree :: Type

foreign import data Node :: Row Tree -> Tree

foreign import data Leaf :: Tree
```
And a tree type that we want to reflect to:
```hs
data Tree'
  = Node' (Array (Tuple String Tree'))
  | Leaf'

derive instance Generic Tree' _

instance Show Tree' where
  show x = genericShow x
```
for writing the `Reflectable` instances we can make use of `reflectRow` in
the `Node` case:
```hs
instance Reflectable Leaf Tree' where
  reflectType _ = Leaf'

instance (ReflectRow r Tree') => Reflectable (Node r) Tree' where
  reflectType _ = Node' $ reflectRow (Proxy :: _ r)
```
For a sample type tree
```hs
type MyTree = Node
  ( a :: Leaf
  , b ::
      Node
        ( c :: Leaf
        )
  )
```
we can verify in the REPL that the reflection works:

```text
> reflectType (Proxy :: _ MyTree)
(Node' [(Tuple "b" (Node' [(Tuple "c" Leaf')])),(Tuple "a" Leaf')])
```