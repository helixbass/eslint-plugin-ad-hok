const MyComponent: FC = flowMax(
  branch(() => true, returns(() => <MyComponent />)),
  () => null
)
