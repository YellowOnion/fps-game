-- |
{-# LANGUAGE FlexibleContexts, FunctionalDependencies, MultiParamTypeClasses,
  UndecidableInstances, OverloadedStrings, TemplateHaskell, TypeApplications,
  TypeFamilies, DataKinds, TypeOperators, FlexibleInstances, RankNTypes,
  AllowAmbiguousTypes, ScopedTypeVariables, DerivingStrategies,
  GeneralizedNewtypeDeriving, LambdaCase, AllowAmbiguousTypes #-}

{-# LANGUAGE BangPatterns, FunctionalDependencies, TypeFamilies, TypeInType, LambdaCase, TypeApplications, AllowAmbiguousTypes #-}

module Game.Utils where

import Godot.Gdnative.Internal.Types
import Godot
import Godot.Core.Object
import qualified Godot.Core.ProjectSettings as PS

import Data.Typeable

is_class' cls str = do
  gdstr <- toLowLevel str
  is_class cls gdstr

get_class' cls = do
  get_class cls >>= fromLowLevel

getPS = do
  Just ps <- getSingleton @ProjectSettings
  return ps

getPSsetting string = getPS >>= flip getPSsetting' string

getPSsetting' ps setting = do
  setting' <- toLowLevel setting
  PS.get_setting ps setting' >>= fromGodotVariant

getPSsettings strings = do
  ps <- getPS
  mapM (getPSsetting' ps) strings

{-
fromVariant' :: forall a. (Typeable a, AsVariant a) => GodotVariant -> IO a
fromVariant' var = do
  v <- fromLowLevel var
  case v of
        VariantBool b -> return b
        VariantInt  i -> return i
        VariantReal r -> return r
        VariantString a -> fromLowLevel a
        VariantVector2 a -> fromLowLevel a
        VariantRect2 a -> fromLowLevel a
        VariantVector3 a -> fromLowLevel a
        VariantTransform2d a -> fromLowLevel a
        VariantPlane a -> fromLowLevel a
        VariantQuat a -> fromLowLevel a
        VariantAabb a -> fromLowLevel a
        VariantBasis a -> fromLowLevel a
        VariantTransform a -> fromLowLevel a
        VariantColor a -> fromLowLevel a
        VariantNodePath a -> fromLowLevel a
        VariantRid a -> fromLowLevel a
        VariantObject a -> fromLowLevel a
        VariantDictionary a -> fromLowLevel a
        VariantArray a -> fromLowLevel a
        VariantPoolByteArray a -> fromLowLevel a
        VariantPoolIntArray a -> fromLowLevel a
        VariantPoolRealArray a -> fromLowLevel a
        VariantPoolStringArray a -> fromLowLevel a
        VariantPoolVector2Array a -> fromLowLevel a
        VariantPoolVector3Array a -> fromLowLevel a
        VariantPoolColorArray a -> fromLowLevel a
-}
