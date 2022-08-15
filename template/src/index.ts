exports.handler = async (event: any) => {
  console.log(`EVENT=>`, JSON.stringify(event, null, 2))
  return {
    statusCode: 200,
    test: 'hello world',
  }
}
