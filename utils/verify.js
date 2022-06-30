const { run } = require("hardhat")

async function verify(contractAddress, args) {
    // auto-verify source code of the contract
    console.log("Verifying contract...")

    try {
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
        })
    } catch (e) {
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("ALREADY VERIFIED")
        } else {
            console.log("FAILED TO VERIFY:", e)
        }
    }
}

module.exports = { verify }
