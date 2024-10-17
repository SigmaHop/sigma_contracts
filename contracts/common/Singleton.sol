// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

abstract contract Singleton {
    // singleton always has to be the first declared variable to ensure the same location as in the Proxy contract.
    // It should also always be ensured the address is stored alone (uses a full word)
    address private singleton;
}
