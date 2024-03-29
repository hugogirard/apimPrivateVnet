param apimName string

var apiName = 'test-api'
var operationName = 'getmsg'

resource testAPi 'Microsoft.ApiManagement/service/apis@2020-12-01' = {
  name: '${apimName}/${apiName}'
  properties: {
    displayName: 'Test API'
    subscriptionRequired: false
    apiRevision: '1'
    path: 'test'
    protocols: [
      'https'
    ]
  }
}

resource testApiOperation 'Microsoft.ApiManagement/service/apis/operations@2020-12-01' = {
  name: '${testAPi.name}/${operationName}'
  dependsOn: [
    testAPi
  ]
  properties: {
    displayName: 'GetMsg'
    method: 'GET'
    urlTemplate: '/'
    templateParameters: [
      
    ]
    responses: [
      {
        statusCode: 200
        representations: [
          {
            contentType: 'application/json'
            sample: '{\r\n "message": "Hello World from East US"\r\n}'
          }          
        ]
        headers: [
          
        ]
      }
    ]
  }
}

resource operationPolicy 'Microsoft.ApiManagement/service/apis/operations/policies@2020-12-01' = {
  name: '${apimName}/${testAPi.name}/policy'
  dependsOn: [
    testApiOperation
  ]
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <base />\r\n    <mock-response status-code="200" content-type="application/json" />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
}
