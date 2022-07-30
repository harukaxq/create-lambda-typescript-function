exports.handler = ( async (event: any) => {
  console.log(event)
  return {
    'statusCode': 200,
    'test': 'hello world'
  }
});
