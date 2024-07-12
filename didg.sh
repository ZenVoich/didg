#!/bin/bash
canister_id="$1"
path="${2:-$1}"
name=$(basename $path)

echo "Generating declarations for canister \"$canister_id\" at \"$path\""

mkdir -p $path

dfx canister metadata --ic $canister_id candid:service > $path/$name.did
didc bind --target js $path/$name.did > $path/$name.did.js
didc bind --target ts $path/$name.did > $path/$name.did.d.ts

cat >$path/index.js <<EOL
import {Actor, HttpAgent} from "@dfinity/agent";

// Imports and re-exports candid interface
import {idlFactory} from "./$name.did.js";
export {idlFactory} from "./$name.did.js";

/**
 * @param {string | import("@dfinity/principal").Principal} canisterId Canister ID of Agent
 * @param {{agentOptions?: import("@dfinity/agent").HttpAgentOptions; actorOptions?: import("@dfinity/agent").ActorConfig} | { agent?: import("@dfinity/agent").Agent; actorOptions?: import("@dfinity/agent").ActorConfig }} [options]
 * @return {import("@dfinity/agent").ActorSubclass<import("./$name.did.js")._SERVICE>}
 */
export const createActor = (canisterId, options = {}) => {
	const agent = options.agent || new HttpAgent({...options.agentOptions});

	if (options.agent && options.agentOptions) {
		console.warn(
			"Detected both agent and agentOptions passed to createActor. Ignoring agentOptions and proceeding with the provided agent."
		);
	}

	// Fetch root key for certificate validation during development
	if (process.env.DFX_NETWORK && process.env.DFX_NETWORK !== "ic") {
		agent.fetchRootKey().catch((err) => {
			console.warn(
				"Unable to fetch root key. Check to ensure that your local replica is running"
			);
			console.error(err);
		});
	}

	// Creates an actor with using the candid interface and the HttpAgent
	return Actor.createActor(idlFactory, {
		agent,
		canisterId,
		...options.actorOptions,
	});
};
EOL