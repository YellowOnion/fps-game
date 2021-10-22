-- |

{-# LANGUAGE FlexibleContexts, FunctionalDependencies, MultiParamTypeClasses,
  UndecidableInstances, OverloadedStrings, TemplateHaskell, TypeApplications,
  TypeFamilies, DataKinds, TypeOperators, FlexibleInstances, RankNTypes,
  AllowAmbiguousTypes, ScopedTypeVariables, DerivingStrategies,
  GeneralizedNewtypeDeriving, LambdaCase #-}


module Game.Player where

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

data Player = Player
  { _pBase         :: BaseClass Player
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
    ps <- getSingleton @ProjectSettings
    return ()
    --a <- fromGodotVariant =<< PS.get_setting ps "physics/3d/default_gravity_vector"
    --swapMVar (_pGVector self) a
    --swapMVar (_pGMag self) =<< fromGodotVariant =<< PS.get_setting ps "physics/3d/default_gravity"
