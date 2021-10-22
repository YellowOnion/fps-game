{-# LANGUAGE OverloadedStrings, TemplateHaskell, MultiParamTypeClasses #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}

{-# LANGUAGE FlexibleContexts, FunctionalDependencies, MultiParamTypeClasses,
  UndecidableInstances, OverloadedStrings, TemplateHaskell, TypeApplications,
  TypeFamilies, DataKinds, TypeOperators, FlexibleInstances, RankNTypes,
  AllowAmbiguousTypes, ScopedTypeVariables, DerivingStrategies,
  GeneralizedNewtypeDeriving, LambdaCase #-}
module Lib
  ( exports
  )
where

import Godot
import Game.Player
import Project.Support
import Project.Requirements

exports :: GdnativeHandle -> IO ()
exports = registerOne @Player
