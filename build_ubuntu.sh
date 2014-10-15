pushd .
git config --global github.token $TOKEN

# build ubuntu
sudo apt-get install libsnappy-dev lcov ggcov
git clone https://github.com/couchbaselabs/forestdb
cd forestdb
COMMIT_MSG=`git log -1 HEAD --pretty=format:%h:%s`
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Debug ../
make all

# run tests
make test_coverage

# push coverage
popd
git clone https://$TOKEN@github.com/tahmmee/fdbcov.git    
cp -r forestdb/coverage/* fdbcov/
cd fdbcov

if ! git diff-index --quiet HEAD --; then
  git add .
  git commit -m "$COMMIT_MSG"
  git status
  git push origin gh-pages
fi

# update ci status
cd ../
echo $COMMIT_MSG > status

if ! git diff-index --quiet HEAD --; then

  git remote add https https://$TOKEN@github.com/tahmmee/fdb-continous-integration.git
  git add status
  git commit -m "$COMMIT_MSG"
  git push https master
fi

