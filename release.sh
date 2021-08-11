#!/usr/bin/env bash
set -e

while getopts v: flag
do
    case "${flag}" in
        v) version=${OPTARG};;
    esac
done

echo $version

./build.sh -c ./config/prod.json

rm -rf ./package
mkdir -p package

echo "{
  \"name\": \"@maplelabs/collateral-locker\",
  \"version\": \"${version}\",
  \"description\": \"Collateral Locker Artifacts and ABIs\",
  \"author\": \"Maple Labs\",
  \"license\": \"AGPLv3\",
  \"repository\": {
    \"type\": \"git\",
    \"url\": \"https://github.com/maple-labs/collateral-locker.git\"
  },
  \"bugs\": {
    \"url\": \"https://github.com/maple-labs/collateral-locker/issues\"
  },
  \"homepage\": \"https://github.com/maple-labs/collateral-locker\"
}" > package/package.json

mkdir -p package/artifacts
mkdir -p package/abis

cat ./out/dapp.sol.json | jq '.contracts | ."contracts/CollateralLockerFactory.sol" | .CollateralLockerFactory' > package/artifacts/CollateralLockerFactory.json
cat ./out/dapp.sol.json | jq '.contracts | ."contracts/CollateralLockerFactory.sol" | .CollateralLockerFactory | .abi' > package/abis/CollateralLockerFactory.json
cat ./out/dapp.sol.json | jq '.contracts | ."contracts/CollateralLocker.sol" | .CollateralLocker' > package/artifacts/CollateralLocker.json
cat ./out/dapp.sol.json | jq '.contracts | ."contracts/CollateralLocker.sol" | .CollateralLocker | .abi' > package/abis/CollateralLocker.json

npm publish ./package --access public

rm -rf ./package
