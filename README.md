# operators

## create a new opeartor
```
./hack/operators.sh [NAME]
```

## Monorepo 
### Go Module
each operator has its own `go.mod`. It should be treated as individual kubebuilder generated project.

### PR build
https://github.com/dzou-hpe/operators-template/pull/3/checks

this shows you how build is done automatically when you created a PR with two new Operators

## Using `kubebuilder`
`cd` in the operator you want to [create API](https://book.kubebuilder.io/quick-start.html#create-an-api) and follow official doc
