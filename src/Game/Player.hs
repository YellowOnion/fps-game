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
import qualified Godot.Core.InputEventMouseMotion as Input
import qualified Godot.Core.InputEventMouseButton as Input
import qualified Godot.Core.Spatial as Spatial
import Godot.Gdnative

import Linear.Metric (normalize)
import Linear.V2
import Linear.V3

import qualified Data.Text    as T
import qualified Data.Text.IO as T

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

-- | Counter-Strike/Quake Mouse coefficient
mouse_coeff = 0.022 * pi / 180

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

    mVec <- fromLowLevel =<< PS.get_setting ps =<< toLowLevel "physics/3d/default_gravity_vector"
    case mVec of
      VariantVector3 vec -> void $ swapMVar (_pGVector self) =<< fromLowLevel vec
      _  -> putStrLn "error loading gravity vector"

    magv <- fromLowLevel =<< PS.get_setting ps =<< toLowLevel "physics/3d/default_gravity"
    case magv of
       VariantReal m -> void $ swapMVar (_pGMag self) m
       _ -> putStrLn "error loading gravity mag"

instance NodeMethod Player "_input" '[GodotVariant] (IO ()) where
  nodeMethod self eventGV = do
    captured <- readMVar (_pCaptured self)
    cam <- getNode' @"CamBase" self
    event :: Object <- fromGodotVariant eventGV
    classStr <- get_class' event
    T.putStrLn classStr
    case classStr of
      "InputEventMouseMotion" -> if captured then do
        [sens, yaw_as] <- getPSsettings ["Input/Mouse/Sensitivity", "Input/Mouse/Yaw_Aspect_Ratio"]
        moEvent :: InputEventMouseMotion <- fromGodotVariant eventGV

        mouseRel :: V2 Float <- fromLowLevel =<< Input.get_relative moEvent

        Spatial.rotate_x cam $ negate (mouseRel ^. _y) * sens * mouse_coeff
        Spatial.rotate_y self $ negate (mouseRel ^. _x) * sens * yaw_as * mouse_coeff

        return ()
        else return ()

      "InputEventMouseButton" -> do
        buEvent :: InputEventMouseButton <- fromGodotVariant eventGV
        isPressed <- Input.is_pressed buEvent
        buIndex <- Input.get_button_index buEvent
        print isPressed
        print buIndex
        if isPressed && buIndex == 1 then setCapture captured else return ()
      _ -> return ()
    where
      setCapture captured = do
        Just inp <- getSingleton @Input
        if captured then do
          Input.set_mouse_mode inp Input._MOUSE_MODE_VISIBLE
          swapMVar (_pCaptured self) False >> return ()
          else do
          Input.set_mouse_mode inp Input._MOUSE_MODE_CAPTURED
          swapMVar (_pCaptured self) True >> return ()

instance NodeMethod Player "_physics_process" '[Float] (IO ()) where
  nodeMethod self delta = do
    readMVar (_pGVector self) >> return ()


setupNode ''Player "Player" "Player"
deriveBase ''Player
