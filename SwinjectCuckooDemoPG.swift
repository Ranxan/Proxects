//: Playground - noun: a place where people can play

import UIKit

/**Implementation*/
/*********************************************************************************************************/
/*********************************************************************************************************/

import Foundation

class XNetworkCaller {
    
    static var urlString = "http://echo.jsontest.com/key/value/one/two"
    
    var url : URL?
    var apiResult : String?
    
    typealias XCallback = (String) -> Void
    
    func makeAPICall(responseCallback: @escaping XCallback) -> Void {
        if url == nil {
            url = URL(string: XNetworkCaller.urlString)!
        }
        
        let request = NSMutableURLRequest( url: url!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            if let data = data {
                
                self.apiResult = String(data:data, encoding:String.Encoding.utf8)!
                
                if self.apiResult == nil {
                    self.apiResult = ""
                }
                
                responseCallback(self.apiResult!)
                
            }
        }
        
        
        task.resume()
    }
    
}

/*********************************************************************************************************/

protocol  XBaseModel {
    
    var data : String { set get }
    
}

/*********************************************************************************************************/
/**
 Expected response ..
 https://jsonplaceholder.typicode.com/posts/1
 
 {
 "one": "two",
 "key": "value"
 }
 
 */

class XModel : XBaseModel {
    
    var data: String {
        get {
            return ""
        }
        
        set(value){
        }
    }
    
    var title : String
    
    init(title:String) {
        self.title = title
        self.data = ""
    }
    
}


/*********************************************************************************************************/
protocol XBaseViewModel {
    
    func callAPI() -> String
    func getValue() -> String
    
}

/*********************************************************************************************************/

class XViewModel : XBaseViewModel {
    
    var model : XBaseModel?
    var xNetworkCaller : XNetworkCaller?
    
    init(model : XBaseModel) {
        self.model = model
    }
    
    func callAPI() -> String {
        xNetworkCaller?.makeAPICall() { response in
            self.model?.data = response
        }
        return ""
    }
    
    func getValue() -> String {
        return (self.model?.data)!
    }
}

/*********************************************************************************************************/

import Swinject
class DIAssembler : Assembly {
    
    func assemble(container: Container) {
        
        container.register(XNetworkCaller.self) {_ in
            XNetworkCaller()
        }
        
        container.register(XBaseModel.self) { _ in
            XModel(title: "XModel")
        }
        
        container.register(XBaseViewModel.self) {r in
            let viewModel = XViewModel(model : r.resolve(XBaseModel)!)
            viewModel.xNetworkCaller = r.resolve(XNetworkCaller.self)
            return viewModel
        }
        
    }
    
}

class XAssembler {
    
    static var sharedInstance = XAssembler()
    private var assembler : Assembler?
    
    func assembleApplicationDepenedencies() -> Assembler {
        if assembler == nil {
            assembler = Assembler([DIAssembler()])
        }
        return assembler!
    }
    
}


/**Test implementation with Mock */
/*********************************************************************************************************/
/*********************************************************************************************************/

import Cuckoo
@testable import MVVMDemoProject

import Foundation

class MockXViewModel: XViewModel, Cuckoo.Mock {
    typealias MocksType = XViewModel
    typealias Stubbing = __StubbingProxy_XViewModel
    typealias Verification = __VerificationProxy_XViewModel
    let cuckoo_manager = Cuckoo.MockManager()
    
    private var observed: XViewModel?
    
    func spy(on victim: XViewModel) -> Self {
        observed = victim
        return self
    }
    
    
    // ["name": "model", "accesibility": "", "@type": "InstanceVariable", "type": "XBaseModel?", "isReadOnly": false]
    override var model: XBaseModel? {
        get {
            return cuckoo_manager.getter("model", original: observed.map { o in return { () -> XBaseModel? in o.model }})
        }
        
        set {
            cuckoo_manager.setter("model", value: newValue, original: observed != nil ? { self.observed?.model = $0 } : nil)
        }
        
    }
    
    // ["name": "xNetworkCaller", "accesibility": "", "@type": "InstanceVariable", "type": "XNetworkCaller?", "isReadOnly": false]
    override var xNetworkCaller: XNetworkCaller? {
        get {
            return cuckoo_manager.getter("xNetworkCaller", original: observed.map { o in return { () -> XNetworkCaller? in o.xNetworkCaller }})
        }
        
        set {
            cuckoo_manager.setter("xNetworkCaller", value: newValue, original: observed != nil ? { self.observed?.xNetworkCaller = $0 } : nil)
        }
        
    }
    
    
    
    
    
    override func callAPI()  -> String {
        
        return cuckoo_manager.call("callAPI() -> String",
                                   parameters: (),
                                   original: observed.map { o in
                                    return { () -> String in
                                        o.callAPI()
                                    }
        })
        
    }
    
    override func getValue()  -> String {
        
        return cuckoo_manager.call("getValue() -> String",
                                   parameters: (),
                                   original: observed.map { o in
                                    return { () -> String in
                                        o.getValue()
                                    }
        })
        
    }
    
    
    struct __StubbingProxy_XViewModel: Cuckoo.StubbingProxy {
        private let cuckoo_manager: Cuckoo.MockManager
        
        init(manager: Cuckoo.MockManager) {
            self.cuckoo_manager = manager
        }
        
        var model: Cuckoo.ToBeStubbedProperty<XBaseModel?> {
            return .init(manager: cuckoo_manager, name: "model")
        }
        
        var xNetworkCaller: Cuckoo.ToBeStubbedProperty<XNetworkCaller?> {
            return .init(manager: cuckoo_manager, name: "xNetworkCaller")
        }
        
        
        func callAPI() -> Cuckoo.StubFunction<(), String> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return .init(stub: cuckoo_manager.createStub("callAPI() -> String", parameterMatchers: matchers))
        }
        
        func getValue() -> Cuckoo.StubFunction<(), String> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return .init(stub: cuckoo_manager.createStub("getValue() -> String", parameterMatchers: matchers))
        }
        
    }
    
    
    struct __VerificationProxy_XViewModel: Cuckoo.VerificationProxy {
        private let cuckoo_manager: Cuckoo.MockManager
        private let callMatcher: Cuckoo.CallMatcher
        private let sourceLocation: Cuckoo.SourceLocation
        
        init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
            self.cuckoo_manager = manager
            self.callMatcher = callMatcher
            self.sourceLocation = sourceLocation
        }
        
        
        var model: Cuckoo.VerifyProperty<XBaseModel?> {
            return .init(manager: cuckoo_manager, name: "model", callMatcher: callMatcher, sourceLocation: sourceLocation)
        }
        
        var xNetworkCaller: Cuckoo.VerifyProperty<XNetworkCaller?> {
            return .init(manager: cuckoo_manager, name: "xNetworkCaller", callMatcher: callMatcher, sourceLocation: sourceLocation)
        }
        
        
        
        @discardableResult
        func callAPI() -> Cuckoo.__DoNotUse<String> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return cuckoo_manager.verify("callAPI() -> String", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
        }
        
        @discardableResult
        func getValue() -> Cuckoo.__DoNotUse<String> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return cuckoo_manager.verify("getValue() -> String", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
        }
        
    }
    
    
}

class XViewModelStub: XViewModel {
    
    override var model: XBaseModel? {
        get {
            return DefaultValueRegistry.defaultValue(for: (XBaseModel?).self)
        }
        
        set { }
        
    }
    
    override var xNetworkCaller: XNetworkCaller? {
        get {
            return DefaultValueRegistry.defaultValue(for: (XNetworkCaller?).self)
        }
        
        set { }
        
    }
    
    
    
    
    
    override func callAPI()  -> String {
        return DefaultValueRegistry.defaultValue(for: String.self)
    }
    
    override func getValue()  -> String {
        return DefaultValueRegistry.defaultValue(for: String.self)
    }
    
}

/*********************************************************************************************************/

import XCTest
import Cuckoo
import Swinject

@testable import MVVMDemoProject

class XTests : XCTestCase {
    
    var container : Container?
    var mock : MockXViewModel?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        container = Container()
        
        container?.register(XBaseModel.self) { r in
            let xModel = XModel(title : "MockXModel")
            xModel.data = "Try me!"
            return xModel
        }
        
        container?.register(XBaseViewModel.self) { r in
            MockXViewModel(model : r.resolve(XBaseModel.self)!)
        }
        
        mock = container?.resolve(XBaseViewModel.self)! as! MockXViewModel
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        container = nil
    }
    
    func testCallAPI() {
        
        /*Configure mock .. */
        let responseData = "{\n   \"one\": \"two\",\n   \"key\": \"value\"\n}\n"
        stub(mock!){ s in
            s.callAPI().then{
                return responseData
            }
        }
        
        /*Assert..*/
        XCTAssertEqual(mock?.callAPI(), responseData)
    }
    
}






