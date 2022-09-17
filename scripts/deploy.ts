import { ethers } from "hardhat";

async function main() {
  const deployContract = await ethers.getContractFactory("crowdFunding");
  
  const contract = await deployContract.deploy("Building of a Digital host=pital", 30, 60000);

  await contract.deployed();

  console.log("Crowdfunding Contract deployed here: ", contract.address);

  // Crowdfunding Contract deployed here:  0xa43B2918745aCD7f8D516B7D0FEE05D532309330
  


}
  

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
