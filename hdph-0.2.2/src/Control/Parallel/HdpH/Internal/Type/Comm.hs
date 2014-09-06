-- TCP-based communication layer; types
--
-- Author: Rob Stewart, Patrick Maier
-----------------------------------------------------------------------------

module Control.Parallel.HdpH.Internal.Type.Comm
  ( -- * internal state of comm layer, incl pre-initial state
    State(..),
    state0,

    -- * payload messages and message queue
    Payload,
    PayloadQ
  ) where

import Prelude
import Control.Concurrent (MVar, Chan)
import Data.ByteString.Lazy as Lazy (ByteString)
import Network.Transport (Transport, EndPoint, Connection)

import Control.Parallel.HdpH.Conf (RTSConf, defaultRTSConf)
import Control.Parallel.HdpH.Internal.Location (Node)
import Control.Parallel.HdpH.Internal.Topology (Bases)


-----------------------------------------------------------------------------
-- state representation

data State =
  State {
    s_conf     :: RTSConf,       -- config data
    s_nodes    :: Int,           -- number of nodes of parallel machine
    s_allNodes :: [Node],        -- all nodes of parallel machine;
                                   -- head of list is this node; OBSOLETE
    s_bases    :: Bases,         -- distance-indexed map of equidistant bases
    s_root     :: Maybe Node,    -- root node (Nothing if this is the root)
    s_msgQ     :: PayloadQ,      -- queue holding received payload messages
    s_tp       :: Transport,     -- this node's transport
    s_ep       :: EndPoint,      -- this node's end point
    s_conns    :: [Connection] } -- connections to all nodes (not scalable)
--  s_shutdown :: MVar () }      -- shutdown signal; OBSOLETE!!!

-- concurrent message queue storing payload messages
type PayloadQ = Chan Payload

-- payload message
type Payload = Lazy.ByteString


-----------------------------------------------------------------------------
-- pre-initial state

-- pre-initial state (as evident from the fields 's_nodes' and 's_allNodes')
-- for the comm layer; used to initialise the IORef
state0 :: State
state0 =
  State {
    s_conf     = defaultRTSConf,
    s_nodes    = 0,       -- 0 nodes; obviously pre-initial
    s_allNodes = [],      -- empty list; obviously pre-initial
    s_root     = Nothing,
    s_bases    = error $ pref ++ "field 's_bases' not initialised",
    s_msgQ     = error $ pref ++ "field 's_msgQ' not initialised",
    s_tp       = error $ pref ++ "field 's_tp' not initialised",
    s_ep       = error $ pref ++ "field 's_ep' not initialised",
    s_conns    = [] }
      where
        pref = "Control.Parallel.HdpH.Internal.State.Comm.stateRef: "