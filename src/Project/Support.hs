-- | This file is AUTOGENERATED by godot-haskell-project-generator. DO NOT EDIT

{-# LANGUAGE FlexibleContexts, FunctionalDependencies, MultiParamTypeClasses,
  UndecidableInstances, OverloadedStrings, TemplateHaskell, TypeApplications,
  TypeFamilies, TupleSections, DataKinds, TypeOperators, FlexibleInstances, RankNTypes,
  AllowAmbiguousTypes, ScopedTypeVariables, DerivingStrategies,
  GeneralizedNewtypeDeriving, LambdaCase #-}

{-# OPTIONS_GHC -Wno-name-shadowing #-}

module Project.Support where
import Prelude
import Godot.Core.Object
import Godot.Internal.Dispatch
import Godot.Gdnative.Internal.Types
import Data.Typeable
import qualified Data.Text as T
import qualified Data.Map as M
import Language.Haskell.TH
import Language.Haskell.TH.Datatype
import Control.Lens
import Control.Monad
import Godot
import Godot.Gdnative
import GHC.TypeLits
import Data.List
import Data.Maybe
import Data.Coerce
import Godot.Core.ResourceLoader
import Godot.Core.PackedScene

-- * Helper to keep Haskell types in sync with the Godot project.
newtype PackedScene' (scene :: Symbol) = PackedScene' PackedScene
                        deriving newtype AsVariant
instance HasBaseClass (PackedScene' scene) where
        type BaseClass (PackedScene' scene) = PackedScene
        super = coerce
deriveBase ''PackedScene'

-- | Use this to register all of your classes, it makes sure that you don't
-- forget a class that Godot needs.
-- 
-- exports :: GdnativeHandle -> IO ()
-- exports desc = registerAll' @Nodes @'[HUD, Main, Mob, Player] desc
registerAll' :: forall (res :: [*]) (ns :: [*]). ImplementedInHaskell res ns => GdnativeHandle -> IO ()
registerAll' = fill @res @ns

-- | A safe version of getNode; gives you back the Godot object
-- getNode' @"MobPath/MobSpawnLocation" self
getNode' :: forall label b cls scene name. (Object :< cls, Node :< cls,
                                      Node :< b,
                                      NodeInScene scene name cls,
                                      SceneNode scene label,
                                      SceneNodeType scene label ~ b,
                                      KnownSymbol label)
         => cls -> IO b
getNode' o = getNode @(SceneNodeType scene label) o (T.pack $ symbolVal (Proxy @label))

-- | A safe version of getNodeNativeScript; gives you back the Haskell object
-- getNodeNativeScript' @"HUD" self
getNodeNativeScript' :: forall label b cls scene name scene' label'.
                        (NativeScript b, Node :< cls, Object :< cls, NodeInScene scene name cls,
                         SceneNodeIsHaskell scene label ~ 'Just '(scene', label'),
                         NodeInScene scene' label' b,
                         KnownSymbol label)
                     => cls -> IO b
getNodeNativeScript' cls = getNodeNativeScript @b cls (T.pack $ symbolVal (Proxy @label))

-- | A safe version of emit_signal; will error at compile time if the signal doesn't exist
-- emit_signal' @"hit" self []
-- TODO We don't check arguments yet!
emit_signal' :: forall label args cls.
               (Object :< cls, Object :< cls, NodeSignal cls label args, KnownSymbol label)
             => cls -> [Variant 'GodotTy] -> IO ()
emit_signal' cls args = do
  name <- toLowLevel (T.pack $ symbolVal (Proxy @label))
  emit_signal cls name args

-- | A safe version of await; will error at compile time if the signal and nodes don't exist
-- await' @"MessageTimer" @"timeout" self $ \self' -> pure ()
await' :: forall (label :: Symbol) (signal :: Symbol) a b cls scene name.
         (NodeInScene scene name cls, NativeScript cls, KnownSymbol label, KnownSymbol signal,
          SceneNode scene label, Node :< cls, AsVariant a, Node :< SceneNodeType scene label,
          NodeSignal b signal '[], SceneNodeType scene label ~ b)
       => cls -> (cls -> IO a) -> IO ()
await' o f = do
  n <- getNode' @label o
  await o n (T.pack $ symbolVal (Proxy @signal)) f

-- | Preload a scene so you can instantiate it later.
-- Use this when the scene is known ahead of time. Store scenes in as @PackedScene' "SceneName"@
preloadScene :: forall scene. (KnownSymbol scene, SceneResourcePath scene) => IO (PackedScene' scene)
preloadScene = do
  Just r <- getSingleton @ResourceLoader
  path <- toLowLevel $ sceneResourcePath @scene
  PackedScene' <$> (tryCast' =<< load r path Nothing Nothing)

-- | Create an instance of a scene from a @PackedScene' "SceneName"@
-- Makes sure that you are getting the type of the scene root.
sceneInstance :: forall scene o. (Node :< o, Typeable o, AsVariant o, SceneNodeType scene (SceneRootNode scene) ~ o) => PackedScene' scene -> IO o
sceneInstance e = tryCast' =<< instance' e Nothing

-- | Combines nodeMethod with getNode' to call functions in a type-safe way
-- Provides no additional safety compared to using the two separately, but does clean up code a bit.
-- For example: fn @"MyNode" @"hide" self
fn :: forall (node :: Symbol) (func :: Symbol) scene name cls args ret b.
         (Object :< cls, Node :< cls,
           Node :< SceneNodeType scene node,
           NodeInScene scene name cls, SceneNode scene node,
           NodeMethodSuper (SceneNodeType scene node) func args ret,
           ListToFun args ret ~ IO b, KnownSymbol node) => cls -> IO b
fn self = nodeMethod' @_ @func =<< getNode' @node self

-- | Get the file path to the scene
class SceneResourcePath (scene :: Symbol) where
  sceneResourcePath :: forall scene. T.Text

-- * Internal helpers: You won't use these

-- | The root node of a scene
class SceneRoot (scene :: Symbol) where
  type SceneRootNode scene :: Symbol

-- | A node in the scene, we know its type and its name, @s@ is the path relate
-- to the scene
class (Typeable (SceneNodeType scene s),
       AsVariant (SceneNodeType scene s),
       Object :< SceneNodeType scene s) => SceneNode (scene :: Symbol) (s :: Symbol) where
  type SceneNodeType scene s :: *
  type SceneNodeName scene s :: Symbol
  type SceneNodeIsHaskell scene s :: Maybe (Symbol, Symbol)

-- | You declare this for your types. You offer up a haskell type, @n@, for the
-- node. This class verifies that your base class is correct.
class (HasBaseClass n, BaseClass n ~ SceneNodeType scene s) =>
      NodeInScene (scene :: Symbol) (s :: Symbol) n | scene s -> n, n -> scene s

-- | A connection between nodes in a scene. @from@ and @to@ are paths.
-- It connects @signal@ in @from@ to @method@ in @to@.
class SceneConnection (scene :: Symbol) (from :: Symbol) (signal :: Symbol) (to :: Symbol) (method :: Symbol)

-- | Internal, just for convenience
data OneResourceNode (resource :: Symbol) (name :: Symbol)

-- | Internal. Don't touch this and don't make instances of it. It's the
-- workhorse for making sure that you are implementing all of the classes that
-- Godot needs, nothing more and nothing less.
class ImplementedInHaskell (a :: [*]) (b :: [*]) where
  fill :: GdnativeHandle -> IO ()

instance ImplementedInHaskell '[] '[] where
  fill _ = pure ()

registerOne :: forall ty. (NativeScript ty, AsVariant (BaseClass ty)) => GdnativeHandle -> IO ()
registerOne desc = registerClass $ RegClass desc $ classInit @ty

instance (NodeInScene scene name n,
          NativeScript n, AsVariant (BaseClass n),
          ImplementedInHaskell t t',
          SceneNodeIsHaskell scene name ~ 'Just '(resource, name))
          => ImplementedInHaskell (OneResourceNode resource name ': t) (n ': t') where
  fill handle = do
    registerOne @n handle
    fill @t @t' handle

-- | Create a signal
-- TODO args ~ '[] is temproary, we need signeltons to reflect this into a runtime value
signal' :: forall cls label args.
          (NodeSignal cls label args, KnownSymbol label, args ~ '[])
        => (Text, [SignalArgument])
signal' = signal (T.pack $ symbolVal (Proxy @label)) []

createMVarProperty' :: (Typeable ty, AsVariant ty) => Text
                    -> (node -> MVar ty)
                    -- ^ We typically can't do IO (for initialisation) when calling this, in
                    -- which case we need to annotate the type without providing a value.
                    -> Either VariantType ty
                    -> (node -> IO ty
                      ,node -> ty -> IO ()
                      ,Maybe (Object -> node -> IO GodotVariant
                             ,Object -> node -> GodotVariant -> IO ()
                             ,PropertyAttributes))
createMVarProperty' name fieldName tyOrVal =
  (readMVar . fieldName,
   \c t -> propertySetter p undefined c =<< toGodotVariant t,
   Just (propertyGetter p, propertySetter p, propertyAttrs p))
  where p = createMVarProperty name fieldName tyOrVal

appsT :: Type -> [Type] -> Type
appsT t [] = t
appsT t (x:xs) = appsT (AppT t x) xs

-- | Verify that the signal connects to an endpoint that exists and has the right type.
witnessConnection :: forall (scene :: Symbol) (from :: Symbol) (signal :: Symbol) (to :: Symbol) (method :: Symbol) parent sigTy hTy.
                    (SceneNode scene to,
                      NodeSignal parent signal sigTy,
                      -- TODO This the check unsound, but SceneNodeType isn't right for this constraint. What is?
                      -- The warning produced because 'from' is not used is a reminder of this issue.
                      -- parent :< SceneNodeType scene from,
                      NodeMethod hTy method sigTy (IO ()),
                      NodeInScene scene to hTy) => ()
witnessConnection = ()

-- | Sets up a class
class NodeInit n where
  init :: BaseClass n -> IO n

-- | You never implement this. It's a helper so that we can have a more
-- polymorphic call to nodeMethod which will work when the method is implemneted
-- for any parent of the current node.
class NodeMethodSuper node (name :: Symbol) (args :: [*]) (ret :: *) | node name -> args, node name -> ret where
  nodeMethod' :: node -> ListToFun args ret

-- | An instance that supports calling nodeMethod' on your parents This can lead
-- to infinite loops in the type checker on error, so we isolate it in
-- NodeMethodSuper instead of NodeMethod.
instance {-# OVERLAPPABLE #-} (NodeMethod (BaseClass node) name arg ret, HasBaseClass node)
    => NodeMethodSuper node name arg ret where
  nodeMethod' = nodeMethod' @node @name @arg @ret

mkProperty' :: forall node (name :: Symbol) ty. (NodeProperty node name ty 'False, KnownSymbol name) => ClassProperty node
mkProperty' = ClassProperty (T.pack $ symbolVal (Proxy @name)) a s g
  where (_,_,Just (g,s,a)) = nodeProperty @node @name @ty @'False

-- | You should use this as:
--   setupNode ''Ty
--   deriveBase ''Ty
-- This will instantiate everything that your Object needs
setupNode :: Name -> String -> String -> Q [Dec]
setupNode ty scene sceneNode = do
  -- Collect information about all scenes
  tree         <- map unTree . classInstances <$> reify ''(:<)
  sceneRoots   <- M.fromList . map unSceneRootNode . familyInstances <$> reify ''SceneRootNode
  sceneNodes   <- map unSceneNodeType . familyInstances <$> reify ''SceneNodeType
  haskellNodes <- map unNodeInScene . classInstances <$> reify ''NodeInScene
  allSignals   <- map unNodeSignal . classInstances <$> reify ''NodeSignal
  -- Collect information about our node
  rdt <- reifyDatatype ty
  let base = case datatypeCons rdt of
                    (c:_) -> case (constructorFields c, constructorVariant c) of
                              (ConT baseTy:_, RecordConstructor (baseFn:_)) -> Just (baseTy, baseFn)
                              _ -> Nothing
                    _ -> Nothing
  --
  methods    <- filter (\i -> i^._1 == ty) . mapMaybe unNodeMethod . classInstances <$> reify ''NodeMethod
  properties <- filter (\i -> i^._1 == ty) . mapMaybe unNodeProperty . classInstances <$> reify ''NodeProperty
  let signals = filter (\i -> i^._1 == ty) allSignals
  connections <- filter (\i -> i^._1 == scene && i^._4 == sceneNode) . map unConnect . classInstances <$> reify ''SceneConnection
  -- Helpers
  let parentsOf cls = map snd $ filter (\(c,_) -> cls == c) tree
  let nodeToType :: String -> String -> Name
      nodeToType scene node = case (hty, ty ^. _4) of
                                (Just t, _) -> t
                                (_, Nothing) -> ty ^. _3
                                (_, Just scene') -> case M.lookup scene' sceneRoots of
                                                Nothing -> error $ "Looking up the root of a scene that is lacking one. This is a bug. " ++ show (scene', scene, node)
                                                Just node' -> nodeToType scene' node'
        where ty  = fromJust $ find (\n -> n^._1 == scene && n^._2 == node) sceneNodes
              hty = (^._3) <$> find (\n -> n^._1 == scene && n^._2 == node) haskellNodes
  let resolveSignalActualClass scene from signal =
        case mapMaybe (\p -> (p,) <$> find (\s -> s^._2 == signal && s^._1 == p) allSignals) $ parentsOf (nodeToType scene from) of
          -- The root issue is that the signal might not yet exist.
          -- If witnessConnection was not unsound, this would not be needed as the error would happen later.
           [] -> error $ "Class " ++ show from ++ " used in scene " ++ show scene ++ " is lacking a signal named " ++ show signal ++ "\n" ++ show (nodeToType scene from) ++ "\n" ++ show (parentsOf (nodeToType scene from))
           (h:_) -> h ^. _1

  -- Debug
  when False $ runIO $ do
    putStrLn "Regenerating .."
    print rdt
    putStrLn "\nScene roots:"
    print sceneRoots
    putStrLn "\nScene nodes types:"
    mapM_ print sceneNodes
    putStrLn "\nMethods:"
    mapM_ print methods
    putStrLn "\nProperties:"
    mapM_ print properties
    putStrLn "\nSignals:"
    mapM_ print allSignals
    mapM_ print signals
    putStrLn "\nConnections:"
    mapM_ print connections
    putStrLn "\nHaskell nodes:"
    mapM_ print haskellNodes

  -- Generate code
  bi <- case base of
    Just (baseTy, baseFn) ->
      [d|instance HasBaseClass $(pure $ PromotedT ty) where
          type BaseClass $(pure $ PromotedT ty) = $(pure $ PromotedT baseTy)
          super = $(pure $ VarE baseFn)|]
    _ -> error "setupNode can only handle records whose first field is the Godot base class. You can still interface with Godot, but you will need to set things up manually."
  nis <- [d|instance NodeInScene $(pure $ LitT $ StrTyLit scene) $(pure $ LitT $ StrTyLit sceneNode) $(pure $ PromotedT ty)|]
  ns <- [d|instance NativeScript $(pure $ PromotedT ty) where
            classInit = Project.Support.init
            classMethods = $(ListE <$> mapM (\(t,n,argTy,_) ->
                     let m = case nrArguments argTy of
                                  0 -> [e|method0|]
                                  1 -> [e|method1|]
                                  2 -> [e|method2|]
                                  3 -> [e|method3|]
                                  4 -> [e|method4|]
                                  5 -> [e|method5|]
                                  n -> error $ "More arguments than we currently impelement, look for 'method5' for more info " ++ show  n
                     in [e|$m $(pure $ LitE $ StringL n) (nodeMethod @ $(pure $ PromotedT t) @ $(pure $ LitT $ StrTyLit n))|]) methods)
            classProperties = $(ListE <$> mapM (\(name,prop,_,_) -> [e|mkProperty' @ $(pure $ PromotedT name) @ $(pure $ LitT $ StrTyLit prop) |]) properties)
            classSignals = $(ListE <$> mapM (\(ty,name,_) -> [e|signal' @ $(pure $ PromotedT ty) @ $(pure $ LitT $ StrTyLit name)|]) signals)|]
  let cn = mkName $ "witness_connections_" ++ nameBase ty
  ws <- (:) <$> (cn `sigD` [t| [()] |]) <*>
       [d|$(varP cn) =
             $(ListE <$> mapM (\(scene,from,signal,to,method) ->
                    [e|witnessConnection
                        @ $(pure $ LitT $ StrTyLit scene)  @ $(pure $ LitT $ StrTyLit from)
                        @ $(pure $ LitT $ StrTyLit signal) @ $(pure $ LitT $ StrTyLit to)
                        @ $(pure $ LitT $ StrTyLit method)
                        @ $(pure $ PromotedT $ resolveSignalActualClass scene from signal)
                    |]) connections)|]
  pure $ bi <> nis <> ns <> ws

  where
      unTree (InstanceD Nothing [] (AppT (AppT _ parent) child) []) = (unName child, unName parent)
      unTree p = error $ "I don't understand this parent " ++ show p
      unName (ConT x) = x
      unName (AppT (ConT x) _) = x
      unName x = error $ "I don't know how to extract the name of this type: " ++ show x
      unSceneRootNode (TySynInstD (TySynEqn Nothing (AppT _ (LitT (StrTyLit scene))) (LitT (StrTyLit node)))) = (scene,node)
      unSceneRootNode x = error $ "Don't know how unpack this SceneRootNode: " ++ show x
      unSceneNodeType (TySynInstD (TySynEqn Nothing (AppT (AppT _ (LitT (StrTyLit scene))) (LitT (StrTyLit node))) ty))
        = (scene,node,unName ty, unpackScene ty)
      unSceneNodeType x = error $ "Don't know how unpack this SceneNodeType: " ++ show x
      unpackScene (ConT _) = Nothing
      unpackScene (AppT (ConT _) (LitT (StrTyLit scene))) = Just scene
      unpackScene x = error $ "Don't know how unpack this Scene: " ++ show x
      unNodeMethod (InstanceD Nothing [] (AppT (AppT (AppT (AppT (ConT _) (ConT cls)) (LitT (StrTyLit name))) arg) ret) []) 
        = Just (cls, name, arg, ret)
      unNodeMethod _ = Nothing
      unNodeProperty (InstanceD Nothing [] (AppT (AppT (AppT (AppT (ConT _) (ConT cls)) (LitT (StrTyLit name))) arg) ret) []) 
        = Just (cls, name, arg, ret)
      unNodeProperty x = error $ show x
      unNodeInScene (InstanceD Nothing [] (AppT (AppT (AppT (ConT _) (LitT (StrTyLit scene))) (LitT (StrTyLit node))) (ConT hty)) [])
        = (scene, node, hty)
      unNodeInScene x = error $ show x
      unNodeSignal (InstanceD Nothing [] (AppT (AppT (AppT (ConT _) (ConT cls)) (LitT (StrTyLit name))) arg) []) = (cls, name, arg)
      unNodeSignal _ = error "Bad signal"
      unConnect (InstanceD Nothing [] (AppT (AppT (AppT (AppT (AppT _ (LitT (StrTyLit scene))) (LitT (StrTyLit from))) (LitT (StrTyLit signal))) (LitT (StrTyLit to))) (LitT (StrTyLit method))) []) = (scene, from, signal, to, method)
      unConnect x = error $ "Bad signal" ++ show x
      nrArguments :: Type -> Int
      nrArguments (AppT _ r) = 1 + nrArguments r
      nrArguments (SigT PromotedNilT (AppT ListT StarT)) = 0
      nrArguments _ = error "Can't compute # of arguments"
      classInstances :: Info -> [InstanceDec]
      classInstances (ClassI _ is) = is
      classInstances _ = error "Bad class"
      familyInstances :: Info -> [InstanceDec]
      familyInstances (FamilyI _ is) = is
      familyInstances _ = error "Bad class"
