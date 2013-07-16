module Type.Inference where

import qualified Data.Map as Map

import qualified Type.Type as T
import qualified Type.Environment as Env
import qualified Type.Constrain.Expression as TcExpr
import qualified Type.Constrain.Declaration as TcDecl
import qualified Type.Solve as Solve

import SourceSyntax.Module
import Text.PrettyPrint
import qualified Type.State as TS
import Control.Monad.State
import Transform.SortDefinitions as Sort


infer :: Module t v -> IO (Either [Doc] (Map.Map String T.Variable))
infer (Module _ _ _ decls) = do
  env <- Env.initialEnvironment
  var <- T.flexibleVar
  let expr = sortDefs (TcDecl.toExpr decls)
  constraint <- TcExpr.constrain env expr (T.VarN var)
  (env,_,_,errors) <- execStateT (Solve.solve constraint) TS.initialState
  if null errors
      then return $ Right env
      else Left `fmap` sequence errors
