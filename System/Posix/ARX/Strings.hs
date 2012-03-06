{-# LANGUAGE OverloadedStrings
           , GeneralizedNewtypeDeriving #-}
module System.Posix.ARX.Strings where

import Control.Monad
import Data.ByteString.Char8
import Data.Maybe
import Data.Monoid
import Prelude hiding (elem, takeWhile)
import Data.String


-- | This type represents the value and not the layout of a C string: a
--   sequence of bytes not containing null.
newtype CString = CString ByteString deriving (Eq, Ord, Show, Monoid)
instance IsString CString where fromString = fromJust . maybeNorm . fromString
instance Bytes CString    where bytes (CString s) = s
instance Norm CString     where norm = CString . takeWhile (/= '\0')

-- | A C string containing an @=@, separating the variable and the value.
newtype Env = Env ByteString deriving (Eq, Ord, Show)
instance IsString Env     where fromString = fromJust . maybeNorm . fromString
instance Bytes Env        where bytes (Env b) = b
instance Norm Env         where norm b | elem '=' c = Env c
                                       | otherwise  = Env (snoc c '=')
                                 where CString c = norm b


class Norm t              where norm :: ByteString -> t

class Bytes t             where bytes :: t -> ByteString

maybeNorm                   ::  (Bytes t, Norm t) => ByteString -> Maybe t
maybeNorm b                  =  guard (bytes normed == b) >> Just normed
 where normed                =  norm b

