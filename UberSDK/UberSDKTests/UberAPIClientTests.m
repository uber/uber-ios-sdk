//
//  UberSDKTests.m
//  UberSDKTests
//
//  Copyright (c) 2015 Uber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <OHHTTPStubs.h>

#import "UberSDK.h"
#import "OHHTTPStubs+UberSDKTests.h"

@interface UberAPIClientTests : XCTestCase

@end

@implementation UberAPIClientTests

- (void)setUp
{
    [UberAPIClient sandbox:YES];
}

- (void)tearDown
{
    [super tearDown];
    
    [OHHTTPStubs removeAllStubs];
}

- (void)testNoToken
{
    XCTAssertThrows([[UberAPIClient alloc] initWithServerToken:nil]);
    XCTAssertThrows([[UberAPIClient alloc] initWithServerToken:@""]);
}

- (void)testInvalidProducts
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:@"/v1/products" file:@"products.json"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    UberAPIClient *client = [[UberAPIClient alloc] initWithServerToken:@"test_token"];
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(999, 999);
    [client productsWithCoordinate:location completion:^(NSArray *products, NSError *error) {
        XCTAssertNotNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

- (void)testProducts
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:@"/v1/products" file:@"products.json"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    UberAPIClient *client = [[UberAPIClient alloc] initWithServerToken:@"test_token"];
    CLLocationCoordinate2D boston = CLLocationCoordinate2DMake(42.3, -71.2);
    [client productsWithCoordinate:boston completion:^(NSArray *products, NSError *error) {
        XCTAssertNil(error);
        XCTAssertEqual(products.count, 5);
        
        UBProduct *product = products[0];
        XCTAssertEqualObjects(product.capacity, @(4));
        XCTAssertEqualObjects(product.productDescription, @"The low-cost Uber");
        XCTAssertEqualObjects(product.imageURL, [NSURL URLWithString:@"http://d1a3f4spazzrp4.cloudfront.net/car.jpg"]);
        XCTAssertEqualObjects(product.displayName, @"uberX");
        XCTAssertEqualObjects(product.productId, @"a1111c8c-c720-46c3-8534-2fcdd730040d");
        
        UBProductPriceDetail *price = product.priceDetail;
        XCTAssertEqualObjects(price.distanceUnit, @"mile");
        XCTAssertEqualObjects(price.costPerMinute, @(0.26));
        XCTAssertEqualObjects(price.costPerDistance, @(1.3));
        XCTAssertEqualObjects(price.minimum, @(5));
        XCTAssertEqualObjects(price.base, @(2.2));
        XCTAssertEqualObjects(price.cancellationFee, @(5));
        XCTAssertEqualObjects(price.currencyCode, @"USD");
        
        NSArray *serviceFees = price.serviceFees;
        XCTAssertEqual(serviceFees.count, 1);
        
        UBPriceDetailServiceFee *fee  = serviceFees[0];
        XCTAssertEqualObjects(fee.name, @"Safe Rides Fee");
        XCTAssertEqualObjects(fee.fee, @(1));
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

- (void)testInvalidPrices
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:@"/v1/estimates/price" file:@"prices.json"];
    
    // invalid start date
    XCTestExpectation *expectationStart = [self expectationWithDescription:@"invalid start"];
    UberAPIClient *client = [[UberAPIClient alloc] initWithServerToken:@"test_token"];
    
    CLLocationCoordinate2D startA = CLLocationCoordinate2DMake(999, 999);
    CLLocationCoordinate2D startB = CLLocationCoordinate2DMake(10, 10);
    [client priceEstimatesWithStartCoordinate:startA endCoordinate:startB completion:^(NSArray *prices, NSError *error) {
        XCTAssertNotNil(error);
        [expectationStart fulfill];
    }];
    
    
    // invalid end date
    XCTestExpectation *expectationEnd = [self expectationWithDescription:@"invalid end"];
    
    CLLocationCoordinate2D endA = CLLocationCoordinate2DMake(10, 10);
    CLLocationCoordinate2D endB = CLLocationCoordinate2DMake(999, 999);
    [client priceEstimatesWithStartCoordinate:endA endCoordinate:endB completion:^(NSArray *prices, NSError *error) {
        XCTAssertNotNil(error);
        
        [expectationEnd fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

- (void)testPrices
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:@"/v1/estimates/price" file:@"prices.json"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    UberAPIClient *client = [[UberAPIClient alloc] initWithServerToken:@"test_token"];
    
    CLLocationCoordinate2D start = CLLocationCoordinate2DMake(10, 10);
    CLLocationCoordinate2D end = CLLocationCoordinate2DMake(10, 10);
    [client priceEstimatesWithStartCoordinate:start endCoordinate:end completion:^(NSArray *prices, NSError *error) {
        XCTAssertNil(error);
        XCTAssertEqual(prices.count, 4);
        
        UBPriceEstimate *price = prices[0];
        XCTAssertEqualObjects(price.productId, @"08f17084-23fd-4103-aa3e-9b660223934b");
        XCTAssertEqualObjects(price.currencyCode, @"USD");
        XCTAssertEqualObjects(price.displayName, @"UberBLACK");
        XCTAssertEqualObjects(price.estimate, @"$23-29");
        XCTAssertEqualObjects(price.lowEstimate, @(23));
        XCTAssertEqualObjects(price.highEstimate, @(29));
        XCTAssertEqualObjects(price.surgeMultiplier, @(1));
        XCTAssertEqualObjects(price.duration, @(640));
        XCTAssertEqualObjects(price.distance, @(5.34));
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

- (void)testInvalidTimes
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:@"/v1/estimates/time" file:@"times.json"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    UberAPIClient *client = [[UberAPIClient alloc] initWithServerToken:@"test_token"];
    
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(999, 999);
    [client timeEstimatesWithStartCoordinate:location completion:^(NSArray *times, NSError *error) {
        XCTAssertNotNil(error);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

- (void)testTimes
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:@"/v1/estimates/time" file:@"times.json"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    UberAPIClient *client = [[UberAPIClient alloc] initWithServerToken:@"test_token"];
    
    CLLocationCoordinate2D start = CLLocationCoordinate2DMake(10, 10);
    [client timeEstimatesWithStartCoordinate:start completion:^(NSArray *times, NSError *error) {
        XCTAssertNil(error);
        XCTAssertEqual(times.count, 4);
        
        UBTimeEstimate *time = times[0];
        XCTAssertEqualObjects(time.productId, @"5f41547d-805d-4207-a297-51c571cf2a8c");
        XCTAssertEqualObjects(time.displayName, @"UberBLACK");
        XCTAssertEqualObjects(time.estimate, @(410));
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

- (void)testInvalidPromotions
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:@"/v1/promotions" file:@"promotions.json"];
    
    // invalid start date
    XCTestExpectation *expectationStart = [self expectationWithDescription:@"invalid start"];
    UberAPIClient *client = [[UberAPIClient alloc] initWithServerToken:@"test_token"];
    
    CLLocationCoordinate2D startA = CLLocationCoordinate2DMake(999, 999);
    CLLocationCoordinate2D startB = CLLocationCoordinate2DMake(10, 10);
    [client promotionWithStartCoordinate:startA endCoordinate:startB completion:^(UBPromotion *promotion, NSError *error) {
        XCTAssertNotNil(error);
        
        [expectationStart fulfill];
    }];
    
    // invalid end date
    XCTestExpectation *expectationEnd = [self expectationWithDescription:@"invalid end"];
    
    CLLocationCoordinate2D endA = CLLocationCoordinate2DMake(10, 10);
    CLLocationCoordinate2D endB = CLLocationCoordinate2DMake(999, 999);
    [client promotionWithStartCoordinate:endA endCoordinate:endB completion:^(UBPromotion *promotion, NSError *error) {
        XCTAssertNotNil(error);
        
        [expectationEnd fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

- (void)testPromotions
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:@"/v1/promotions" file:@"promotions.json"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    UberAPIClient *client = [[UberAPIClient alloc] initWithServerToken:@"test_token"];
    CLLocationCoordinate2D start = CLLocationCoordinate2DMake(10, 10);
    CLLocationCoordinate2D end = CLLocationCoordinate2DMake(10, 10);
    [client promotionWithStartCoordinate:start endCoordinate:end completion:^(UBPromotion *promotion, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(promotion);
        
        XCTAssertEqualObjects(promotion.displayText, @"Free ride up to $30");
        XCTAssertEqualObjects(promotion.localizedValue, @"$30");
        XCTAssertEqualObjects(promotion.type, @"trip_credit");
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

- (void)testTripHistory
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:@"/v1.2/history" file:@"history.json"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    UberAPIClient *client = [[UberAPIClient alloc] initWithAccessToken:@"test_token"];
    [client userActivityWithOffset:0
                             limit:0
                        completion:^(NSArray *userActivities,
                                     NSInteger offset,
                                     NSInteger limit,
                                     NSInteger count,
                                     NSError *error) {
        
        XCTAssertNil(error);
        XCTAssertEqual(userActivities.count, 3);
                                                     
        XCTAssertEqual(offset, 1);
        XCTAssertEqual(limit, 2);
        XCTAssertEqual(count, 5);
        
        UBUserActivity *trip = userActivities[0];
        XCTAssertEqualObjects(trip.requestId, @"37d57a99-2647-4114-9dd2-c43bccf4c30b");
        XCTAssertEqualObjects(trip.productId, @"a1111c8c-c720-46c3-8534-2fcdd730040d");
        XCTAssertEqualObjects(trip.status, @"completed");
        XCTAssertEqualObjects(trip.distance, @(1.64691465));
        XCTAssertEqualObjects(trip.requestTime, @(1428876188));
        XCTAssertEqualObjects(trip.startTime, @(1428876374));
        XCTAssertEqualObjects(trip.endTime, @(1428876927));
        
        XCTAssertEqualObjects(trip.startCity.latitude, @(37.7749295));
        XCTAssertEqualObjects(trip.startCity.longitude, @(-122.4194155));
        XCTAssertEqualObjects(trip.startCity.displayName, @"San Francisco");
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

- (void)testProfile
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:@"/v1/me" file:@"profile.json"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    UberAPIClient *client = [[UberAPIClient alloc] initWithAccessToken:@"test_token"];
    [client userProfile:^(UBUserProfile *userProfile, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(userProfile);
        
        XCTAssertEqualObjects(userProfile.firstName, @"Uber");
        XCTAssertEqualObjects(userProfile.lastName, @"Developer");
        XCTAssertEqualObjects(userProfile.email, @"developer@uber.com");
        XCTAssertEqualObjects(userProfile.pictureURL, [NSURL URLWithString:@"https://example.com/profile.png"]);
        XCTAssertEqualObjects(userProfile.promoCode, @"teypo");
        XCTAssertEqualObjects(userProfile.uuid, @"91d81273-45c2-4b57-8124-d0165f8240c0");
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

- (void)testInvalidRequest
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:@"/v1/requests" file:@"requests.json"];
    
    // nil product id
    XCTestExpectation *expectationProductIdNil = [self expectationWithDescription:@"invalid product id"];
    UberAPIClient *client = [[UberAPIClient alloc] initWithServerToken:@"test_token"];
    
    [client requestRideWithProductId:nil startCoordinate:CLLocationCoordinate2DMake(1.0, 1.0) endCoordinate:kCLLocationCoordinate2DInvalid surgeConfirmationId:nil completion:^(UBRide *request, UBSurgeConfirmation *surgeConfirmation, NSError *error) {
        
        XCTAssertNotNil(error);
        
        [expectationProductIdNil fulfill];
    }];
    
    // empty product id
    XCTestExpectation *expectationProductIdEmpty = [self expectationWithDescription:@"empty product id"];
    [client requestRideWithProductId:@"" startCoordinate:CLLocationCoordinate2DMake(1.0, 1.0) endCoordinate:kCLLocationCoordinate2DInvalid surgeConfirmationId:nil completion:^(UBRide *request, UBSurgeConfirmation *surgeConfirmation, NSError *error) {
        
        XCTAssertNotNil(error);
        
        [expectationProductIdEmpty fulfill];
    }];
    
    // invalid start
    XCTestExpectation *expectationStart = [self expectationWithDescription:@"invalid start"];
    CLLocationCoordinate2D start = CLLocationCoordinate2DMake(999, 999);
    [client requestRideWithProductId:@"test_product_id" startCoordinate:start
                       endCoordinate:kCLLocationCoordinate2DInvalid
                 surgeConfirmationId:nil
                          completion:^(UBRide *request, UBSurgeConfirmation *surgeConfirmation, NSError *error) {
        
        XCTAssertNotNil(error);
        
        [expectationStart fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

- (void)testRequest
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:@"/v1/requests" file:@"request.json"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    UberAPIClient *client = [[UberAPIClient alloc] initWithAccessToken:@"test_token"];
    [client requestRideWithProductId:@"test_product_id" startCoordinate:CLLocationCoordinate2DMake(10.0, 10.0) endCoordinate:kCLLocationCoordinate2DInvalid surgeConfirmationId:nil completion:^(UBRide *ride, UBSurgeConfirmation *surgeConfirmation, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(ride);
        
        XCTAssertEqualObjects(ride.requestId, @"b2205127-a334-4df4-b1ba-fc9f28f56c96");
        XCTAssertEqualObjects(ride.status, @"accepted");
        XCTAssertEqualObjects(ride.eta, @(4));
        XCTAssertEqualObjects(ride.surgeMultiplier, @(1.0));
        
        XCTAssertEqualObjects(ride.driver.name, @"Bob");
        XCTAssertEqualObjects(ride.driver.phoneNumber, @"(555)555-5555");
        XCTAssertEqualObjects(ride.driver.pictureURL, [NSURL URLWithString:@"https://d1w2poirtb3as9.cloudfront.net/img.jpeg"]);
        XCTAssertEqualObjects(ride.driver.rating, @(5));
        
        XCTAssertEqualObjects(ride.vehicle.make, @"Bugatti");
        XCTAssertEqualObjects(ride.vehicle.model, @"Veyron");
        XCTAssertEqualObjects(ride.vehicle.pictureURL, [NSURL URLWithString:@"https://d1w2poirtb3as9.cloudfront.net/car.jpeg"]);
        XCTAssertEqualObjects(ride.vehicle.licensePlate, @"I<3Uber");
        
        XCTAssertEqualObjects(ride.location.latitude, @(37.776033));
        XCTAssertEqualObjects(ride.location.longitude, @(-122.418143));
        XCTAssertEqualObjects(ride.location.bearing, @(33));
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

- (void)testInvalidRequestDetails
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:nil file:@"requests.json"];
    
    // nil product id
    XCTestExpectation *expectationProductIdNil = [self expectationWithDescription:@"invalid product id"];
    UberAPIClient *client = [[UberAPIClient alloc] initWithServerToken:@"test_token"];
    [client rideDetailsWithRequestId:nil completion:^(UBRide *request, NSError *error) {
        
        XCTAssertNotNil(error);
        
        [expectationProductIdNil fulfill];
    }];
    
    // empty product id
    XCTestExpectation *expectationProductIdEmpty = [self expectationWithDescription:@"empty product id"];
    [client rideDetailsWithRequestId:@"" completion:^(UBRide *request, NSError *error) {
        
        XCTAssertNotNil(error);
        
        [expectationProductIdEmpty fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

- (void)testRequestDetails
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:nil file:@"request.json"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    UberAPIClient *client = [[UberAPIClient alloc] initWithAccessToken:@"test_token"];
    [client rideDetailsWithRequestId:@"test_request_id" completion:^(UBRide *ride, NSError *error) {
        
        XCTAssertNil(error);
        XCTAssertNotNil(ride);
        
        XCTAssertEqualObjects(ride.requestId, @"b2205127-a334-4df4-b1ba-fc9f28f56c96");
        XCTAssertEqualObjects(ride.status, @"accepted");
        XCTAssertEqualObjects(ride.eta, @(4));
        XCTAssertEqualObjects(ride.surgeMultiplier, @(1.0));
        
        XCTAssertEqualObjects(ride.driver.name, @"Bob");
        XCTAssertEqualObjects(ride.driver.phoneNumber, @"(555)555-5555");
        XCTAssertEqualObjects(ride.driver.pictureURL, [NSURL URLWithString:@"https://d1w2poirtb3as9.cloudfront.net/img.jpeg"]);
        XCTAssertEqualObjects(ride.driver.rating, @(5));
        
        XCTAssertEqualObjects(ride.vehicle.make, @"Bugatti");
        XCTAssertEqualObjects(ride.vehicle.model, @"Veyron");
        XCTAssertEqualObjects(ride.vehicle.pictureURL, [NSURL URLWithString:@"https://d1w2poirtb3as9.cloudfront.net/car.jpeg"]);
        XCTAssertEqualObjects(ride.vehicle.licensePlate, @"I<3Uber");
        
        XCTAssertEqualObjects(ride.location.latitude, @(37.776033));
        XCTAssertEqualObjects(ride.location.longitude, @(-122.418143));
        XCTAssertEqualObjects(ride.location.bearing, @(33));
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

- (void)testInvalidCancelRequest
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:nil file:nil];
    
    // nil product id
    XCTestExpectation *expectationRequestIdNil = [self expectationWithDescription:@"nil request id"];
    UberAPIClient *client = [[UberAPIClient alloc] initWithServerToken:@"test_token"];
    
    [client cancelRideWithRequestId:nil completion:^(NSError *error) {
        
        XCTAssertNotNil(error);
        
        [expectationRequestIdNil fulfill];
    }];
    
    // empty product id
    XCTestExpectation *expectationRequestIdEmpty = [self expectationWithDescription:@"empty request id"];
    [client cancelRideWithRequestId:@"" completion:^(NSError *error) {
        
        XCTAssertNotNil(error);
        
        [expectationRequestIdEmpty fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

- (void)testInvalidMapRequest
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:nil file:nil];
    
    // nil product id
    XCTestExpectation *expectationRequestIdNil = [self expectationWithDescription:@"nil request id"];
    UberAPIClient *client = [[UberAPIClient alloc] initWithServerToken:@"test_token"];
    
    [client rideMapWithRequestId:nil completion:^(NSURL *rideMapURL, NSError *error) {
        
        XCTAssertNotNil(error);
        
        [expectationRequestIdNil fulfill];
    }];
    
    // empty product id
    XCTestExpectation *expectationRequestIdEmpty = [self expectationWithDescription:@"empty request id"];
    [client rideMapWithRequestId:@"" completion:^(NSURL *rideMapURL, NSError *error) {
        
        XCTAssertNotNil(error);
        
        [expectationRequestIdEmpty fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

- (void)testInvalidRequestEstimate
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:@"/v1/requests/estimate" file:@"requests_estimate.json"];
    
    // nil product id
    XCTestExpectation *expectationProductIdNil = [self expectationWithDescription:@"invalid product id"];
    UberAPIClient *client = [[UberAPIClient alloc] initWithServerToken:@"test_token"];
    
    [client requestEstimateWithProductId:nil startCoordinate:CLLocationCoordinate2DMake(1.0, 1.0) endCoordinate:kCLLocationCoordinate2DInvalid completion:^(UBRideEstimate *estimate, NSError *error) {
        
        XCTAssertNotNil(error);
        
        [expectationProductIdNil fulfill];
    }];
    
    // empty product id
    XCTestExpectation *expectationProductIdEmpty = [self expectationWithDescription:@"empty product id"];
    [client requestEstimateWithProductId:@"" startCoordinate:CLLocationCoordinate2DMake(1.0, 1.0) endCoordinate:kCLLocationCoordinate2DInvalid completion:^(UBRideEstimate *estimate, NSError *error) {
        
        [expectationProductIdEmpty fulfill];
    }];
    
    // invalid start
    XCTestExpectation *expectationStart = [self expectationWithDescription:@"invalid start"];
    CLLocationCoordinate2D start = CLLocationCoordinate2DMake(999, 999);
    [client requestEstimateWithProductId:@"" startCoordinate:start endCoordinate:kCLLocationCoordinate2DInvalid completion:^(UBRideEstimate *estimate, NSError *error) {
        
        XCTAssertNotNil(error);
        
        [expectationStart fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

- (void)testRequestEstimate
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:@"/v1/requests/estimate" file:@"request_estimate.json"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    UberAPIClient *client = [[UberAPIClient alloc] initWithAccessToken:@"test_token"];
    [client requestEstimateWithProductId:@"test_product_id" startCoordinate:CLLocationCoordinate2DMake(1.0, 1.0) endCoordinate:kCLLocationCoordinate2DInvalid completion:^(UBRideEstimate *estimate, NSError *error) {
        
        XCTAssertNil(error);
        XCTAssertNotNil(estimate);
        
        XCTAssertEqualObjects(estimate.pickupEstimate, @(2));

        XCTAssertEqualObjects(estimate.price.surgeConfirmationURL, [NSURL URLWithString:@"https://api.uber.com/v1/surge-confirmations/7d604f5e"]);
        XCTAssertEqualObjects(estimate.price.surgeConfirmationId, @"7d604f5e");
        XCTAssertEqualObjects(estimate.price.surgeMultiplier, @(1.2));
        XCTAssertEqualObjects(estimate.price.highEstimate, @(6));
        XCTAssertEqualObjects(estimate.price.lowEstimate, @(5));
        XCTAssertEqualObjects(estimate.price.minimum, @(5));
        XCTAssertEqualObjects(estimate.price.display, @"$5-6");
        XCTAssertEqualObjects(estimate.price.currencyCode, @"USD");
        
        XCTAssertEqualObjects(estimate.trip.distanceUnit, @"mile");
        XCTAssertEqualObjects(estimate.trip.distanceEstimate, @(2.1));
        XCTAssertEqualObjects(estimate.trip.durationEstimate, @(9));
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

- (void)testInvalidMapReceipt
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:nil file:nil];
    
    // nil product id
    XCTestExpectation *expectationRequestIdNil = [self expectationWithDescription:@"nil request id"];
    UberAPIClient *client = [[UberAPIClient alloc] initWithServerToken:@"test_token"];
    
    [client rideReceiptWithRequestId:nil completion:^(UBRideReceipt *receipt, NSError *error) {
        
        XCTAssertNotNil(error);
        
        [expectationRequestIdNil fulfill];
    }];
    
    // empty product id
    XCTestExpectation *expectationRequestIdEmpty = [self expectationWithDescription:@"empty request id"];
    [client rideReceiptWithRequestId:@"" completion:^(UBRideReceipt *receipt, NSError *error) {
        
        XCTAssertNotNil(error);
        
        [expectationRequestIdEmpty fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

- (void)testReceipt
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:nil file:@"receipt.json"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    UberAPIClient *client = [[UberAPIClient alloc] initWithAccessToken:@"test_token"];
    [client rideReceiptWithRequestId:@"test_request_id" completion:^(UBRideReceipt *receipt, NSError *error) {
        
        XCTAssertNil(error);
        XCTAssertNotNil(receipt);
        
        XCTAssertEqualObjects(receipt.requestId, @"b5512127-a134-4bf4-b1ba-fe9f48f56d9d");
        XCTAssertEqualObjects(receipt.normalFare, @"$8.52");
        XCTAssertEqualObjects(receipt.subtotal, @"$12.78");
        XCTAssertEqualObjects(receipt.totalCharged, @"$5.92");
        XCTAssertNil(receipt.totalOwed);
        XCTAssertEqualObjects(receipt.currencyCode, @"USD");
        XCTAssertEqualObjects(receipt.duration, @"00:11:35");
        XCTAssertEqualObjects(receipt.distanceLabel, @"miles");
        XCTAssertEqualObjects(receipt.distance, @"1.49");
        
        XCTAssertEqualObjects(receipt.surgeCharge.name, @"Surge x1.5");
        XCTAssertEqualObjects(receipt.surgeCharge.amount, @"4.26");
        XCTAssertEqualObjects(receipt.surgeCharge.type, @"surge");
        
        NSArray *charges = receipt.charges;
        XCTAssertEqual(charges.count, 3);
        UBRideReceiptCharge *charge = charges[0];
        XCTAssertEqualObjects(charge.name, @"Base Fare");
        XCTAssertEqualObjects(charge.amount, @"2.20");
        XCTAssertEqualObjects(charge.type, @"base_fare");
        
        charges = receipt.chargeAdjustments;
        XCTAssertEqual(charges.count, 3);
        charge = charges[0];
        XCTAssertEqualObjects(charge.name, @"Promotion");
        XCTAssertEqualObjects(charge.amount, @"-2.43");
        XCTAssertEqualObjects(charge.type, @"promotion");
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

- (void)testInvalidSandboxProducts
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:nil file:nil];
    
    // nil product id
    XCTestExpectation *expectationProductIdNil = [self expectationWithDescription:@"invalid product id"];
    UberAPIClient *client = [[UberAPIClient alloc] initWithServerToken:@"test_token"];
    
    [client updateSandboxProductWithProductId:nil driversAvailable:YES surge:1.0 completion:^(NSError *error) {
        
        XCTAssertNotNil(error);
        
        [expectationProductIdNil fulfill];
    }];
    
    // empty product id
    XCTestExpectation *expectationProductIdEmpty = [self expectationWithDescription:@"empty product id"];
    [client updateSandboxProductWithProductId:@"" driversAvailable:YES surge:1.0 completion:^(NSError *error) {
        
        XCTAssertNotNil(error);
        
        [expectationProductIdEmpty fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

- (void)testInvalidSandboxRequest
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:nil file:nil];
    
    // nil product id
    XCTestExpectation *expectationRequestIdNil = [self expectationWithDescription:@"nil request id"];
    UberAPIClient *client = [[UberAPIClient alloc] initWithServerToken:@"test_token"];
    
    [client updateSandboxRideWithRequestId:nil status:@"test_status" completion:^(NSError *error) {
        
        XCTAssertNotNil(error);
        
        [expectationRequestIdNil fulfill];
    }];
    
    // empty product id
    XCTestExpectation *expectationRequestIdEmpty = [self expectationWithDescription:@"empty request id"];
    [client updateSandboxRideWithRequestId:@"" status:@"test_status" completion:^(NSError *error) {
        XCTAssertNotNil(error);
        
        [expectationRequestIdEmpty fulfill];
    }];
    
    // nil status
    XCTestExpectation *expectationStatusNil = [self expectationWithDescription:@"nil status"];
    [client updateSandboxRideWithRequestId:@"test_request" status:nil completion:^(NSError *error) {
        XCTAssertNotNil(error);
        
        [expectationStatusNil fulfill];
    }];
    
    // empty status
    XCTestExpectation *expectationStatusEmpty = [self expectationWithDescription:@"empty status"];
    [client updateSandboxRideWithRequestId:@"test_request" status:@"" completion:^(NSError *error) {
        XCTAssertNotNil(error);
        
        [expectationStatusEmpty fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        [client.session invalidateAndCancel];
    }];
}

@end
