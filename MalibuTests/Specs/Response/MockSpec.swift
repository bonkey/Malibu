@testable import Malibu
import Quick
import Nimble
import When

class MockSpec: QuickSpec {

  override func spec() {
    describe("Mock") {
      var mock: Mock!
      let request = GETRequest()
      var response = HTTPURLResponse(url: URL(string: "http://hyper.no")!,
                                       statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)!
      let data = "test".data(using: String.Encoding.utf32)
      let error = NetworkError.noDataInResponse

      describe("#init:request:response:data:error") {
        beforeEach {
          mock = Mock(request: request, response: response, data: data, error: error, delay: 0.1)
        }

        it("sets properties") {
          expect(mock.request.message).to(equal(request.message))
          expect(mock.response).to(equal(response))
          expect(mock.data).to(equal(data))
          expect(mock.error as! NetworkError == error).to(beTrue())
          expect(mock.delay).to(equal(0.1))
        }
      }

      describe("#init:request:fileName:bundle") {
        let fileName = "mock.json"
        var wave: Wave!

        beforeEach {
          mock = Mock(request: request, fileName: fileName, bundle: Bundle(for: MockSpec.self))
          response = HTTPURLResponse(url: URL(string: fileName)!, statusCode: 200,
            httpVersion: "HTTP/2.0", headerFields: nil)!
          wave = Wave(
            data: mock.data!,
            request: try! mock.request.toUrlRequest(),
            response: mock.response!)
        }

        it("sets properties") {
          let contentTypeValidator = ContentTypeValidator(contentTypes: ["application/json"])
          let statusCodeValidator = StatusCodeValidator(statusCodes: [200])
          let serializer = JsonSerializer()
          let dictionary = try! serializer.serialize(data: mock.data!, response: response) as! [String: String]

          expect(mock.request.message).to(equal(request.message))
          expect(mock.response?.statusCode).to(equal(response.statusCode))
          expect(mock.error).to(beNil())
          expect{ try contentTypeValidator.validate(wave) }.toNot(throwError())
          expect{ try statusCodeValidator.validate(wave) }.toNot(throwError())
          expect(dictionary["first_name"]).to(equal("John"))
          expect(dictionary["last_name"]).to(equal("Hyperseed"))
          expect(dictionary["email"]).to(equal("ios@hyper.no"))
        }
      }

      describe("#init:request:JSON") {
        let json = [
          "first_name" : "John",
          "last_name" : "Hyperseed",
          "email" : "ios@hyper.no"
        ]

        var wave: Wave!

        beforeEach {
          mock = Mock(request: request, json: json)
          response = HTTPURLResponse(url: URL(string: "mock://JSON")!, statusCode: 200,
            httpVersion: "HTTP/2.0", headerFields: nil)!
          wave = Wave(
            data: mock.data!,
            request: try! mock.request.toUrlRequest(),
            response: mock.response!)
        }

        it("sets properties") {
          let contentTypeValidator = ContentTypeValidator(contentTypes: ["application/json"])
          let statusCodeValidator = StatusCodeValidator(statusCodes: [200])
          let serializer = JsonSerializer()
          let dictionary = try! serializer.serialize(data: mock.data!, response: response) as! [String: String]

          expect(mock.request.message).to(equal(request.message))
          expect(mock.response?.statusCode).to(equal(response.statusCode))
          expect(mock.error).to(beNil())
          expect{ try contentTypeValidator.validate(wave) }.toNot(throwError())
          expect{ try statusCodeValidator.validate(wave) }.toNot(throwError())
          expect(dictionary["first_name"]).to(equal("John"))
          expect(dictionary["last_name"]).to(equal("Hyperseed"))
          expect(dictionary["email"]).to(equal("ios@hyper.no"))
        }
      }
    }
  }
}
