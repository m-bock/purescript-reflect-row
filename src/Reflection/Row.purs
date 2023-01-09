module Reflection.Row where

import Data.Array as Arr
import Data.Reflectable (class Reflectable, reflectType)
import Data.Tuple (Tuple(..))
import Prim.RowList (class RowToList, RowList)
import Prim.RowList as RL
import Type.Proxy (Proxy(..))

--- ReflectRow

class ReflectRow :: forall k. Row k -> Type -> Constraint
class ReflectRow r t where
  reflectRow :: Proxy r -> Array (Tuple String t)

instance
  ( RowToList r rl
  , ReflectRowList rl t
  ) =>
  ReflectRow r t where
  reflectRow _ = reflectRowList (Proxy :: _ rl)

--- ReflectRowList

class ReflectRowList :: forall k. RowList k -> Type -> Constraint
class ReflectRowList rl t where
  reflectRowList :: Proxy rl -> Array (Tuple String t)

instance ReflectRowList RL.Nil t where
  reflectRowList _ = []

instance
  ( ReflectRowList rl t
  , Reflectable a t
  , Reflectable sym String
  ) =>
  ReflectRowList (RL.Cons sym a rl) t where
  reflectRowList _ = Arr.snoc tail head
    where
    head = Tuple
      (reflectType (Proxy :: _ sym))
      (reflectType (Proxy :: _ a))
    tail = reflectRowList (Proxy :: _ rl)
