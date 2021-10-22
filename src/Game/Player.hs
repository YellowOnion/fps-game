{-# LANGUAGE FlexibleContexts, FunctionalDependencies, MultiParamTypeClasses,
  UndecidableInstances, OverloadedStrings, TemplateHaskell, TypeApplications,
  TypeFamilies, DataKinds, TypeOperators, FlexibleInstances, RankNTypes,
  AllowAmbiguousTypes, ScopedTypeVariables, DerivingStrategies,
  GeneralizedNewtypeDeriving, LambdaCase #-}


module Game.Player where

import Control.Monad
import Control.Lens

import Godot
import qualified Godot.Core.ProjectSettings as PS
import qualified Godot.Core.Camera as Camera
import qualified Godot.Core.KinematicBody as KB
import qualified Godot.Core.Input as Input
import Godot.Gdnative

import Linear.Metric (normalize)
import Linear.V3


import Project.Support
import Project.Scenes.Player ()

import Game.Utils

data Player = Player
  { _pBase         :: KinematicBody
  , _pVelocity     :: MVar (V3 Float)
  , _pAirTime      :: MVar (Float)
  , _pJumpCooldown :: MVar (Float)
  , _pSnapVector   :: MVar (V3 Float)
  , _pTimeOnWall   :: MVar (Float)
  , _pCaptured     :: MVar (Bool)
  , _pTick         :: MVar (Int)
  , _pGVector      :: MVar (V3 Float)
  , _pGMag         :: MVar (Float)
  }

instance NodeInit Player where
  init base = Player
               base
              <$> newMVar (V3 0 0 0)
              <*> newMVar 0
              <*> newMVar 0
              <*> newMVar (V3 0 0 0)
              <*> newMVar 1
              <*> newMVar False
              <*> newMVar 0
              <*> newMVar (V3 0 0 0)
              <*> newMVar 0

instance NodeMethod Player "_ready" '[] (IO ()) where
  nodeMethod self = do
    Just ps <- getSingleton @ProjectSettings
    gvecv :: GodotVariant <- PS.get_setting ps =<< toLowLevel "physics/3d/default_gravity_vector"
    vecv <- fromLowLevel gvecv
    case vecv of
      VariantVector3 vec -> void $ swapMVar (_pGVector self) =<< fromLowLevel vec
      _ -> putStrLn "error loading settings"
    magv <- fromLowLevel =<< PS.get_setting ps =<< toLowLevel "physics/3d/default_gravity"
    case magv of
       VariantReal m -> void $ swapMVar (_pGMag self) m
       _ -> putStrLn "error loading gravity mag"

instance NodeMethod Player "_physics_process" '[Float] (IO ()) where
  nodeMethod self delta = do
    readMVar (_pGVector self) >>= print


setupNode ''Player "Player" "Player"
deriveBase ''Player
