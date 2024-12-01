<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>날씨 및 관광 정보 앱</title>
    <!-- 제이쿼리, UI 추가 -->
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>

    <!-- 폰트어썸 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">

    <style>
        body {
            font-family: 'Montserrat', sans-serif;
            background-color: #1e1e2f; /* 어두운 배경색 */
            color: #ffffff;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh; /* 화면 전체 높이를 기준으로 가운데 정렬 */
        }

        .container {
            background-color: #2a2a3e; /* 다크 모드 카드 배경 */
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4); /* 강한 그림자 */
            padding: 40px;
            width: 90%;
            max-width: 600px;
            text-align: center;
        }

        input[type="text"] {
            width: 100%;
            padding: 15px;
            margin-bottom: 20px;
            border: 2px solid #444466; /* 어두운 테두리 */
            border-radius: 10px;
            background-color: #1e1e2f; /* 다크 모드 입력 필드 배경 */
            color: #ffffff;
            font-size: 16px;
            outline: none;
            transition: all 0.3s ease-in-out;
        }

        input[type="text"]::placeholder {
            color: #77778b; /* 입력 필드의 힌트 색상 */
        }

        input[type="text"]:focus {
            border-color: #7f5af0; /* 포커스 시 보라색 강조 */
            box-shadow: 0 0 8px rgba(127, 90, 240, 0.8);
        }

        button {
            background-color: #7f5af0; /* 버튼 기본 색상 */
            color: #ffffff;
            border: none;
            padding: 12px 25px;
            border-radius: 10px;
            cursor: pointer;
            font-size: 16px;
            transition: background-color 0.3s ease, transform 0.2s ease;
        }

        button:hover {
            background-color: #5a3fc0; /* 호버 시 더 어두운 보라색 */
            transform: scale(1.05); /* 약간 확대 */
        }

        .info-container {
            display: flex;
            flex-direction: column;
            gap: 20px;
            margin-top: 30px;
        }

        .weather-info, .tourist-info {
            background-color: #2d2d42; /* 어두운 카드 배경 */
            padding: 20px;
            border-radius: 12px;
            border: 1px solid #444466;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
            text-align: left;
        }

        .weather-info h2, .tourist-info h2 {
            font-size: 18px;
            color: #7f5af0; /* 보라색으로 강조 */
        }

        p {
            font-size: 14px;
            color: #dddddd;
            margin: 8px 0;
        }

        #prevPage, #nextPage {
            padding: 10px 20px;
            border-radius: 8px;
            border: 1px solid #444466;
            background-color: #1e1e2f;
            color: #7f5af0;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        #prevPage:hover, #nextPage:hover {
            background-color: #7f5af0;
            color: #ffffff;
            border: 1px solid #5a3fc0;
        }

        @media (max-width: 768px) {
            .container {
                width: 90%;
                padding: 30px;
            }

            .info-container {
                flex-direction: column;
                gap: 15px;
            }

            button {
                font-size: 14px;
            }

            input[type="text"] {
                font-size: 14px;
            }
        }
    </style>




<body>

<div class="container">
    <h1>날씨 및 관광 정보 조회</h1>
    <input type="text" id="cityInput" placeholder="도시 이름을 입력하세요"/>
    <button id="getWeatherBtn">조회</button>

    <!-- 날씨와 관광지 정보를 가로로 배치하는 컨테이너 -->
    <div class="info-container">
        <div id="weatherInfo" class="weather-info"></div>
        <div id="touristInfo" class="tourist-info"></div> <!-- 관광지 정보 영역 추가 -->
    </div>
</div>

<script>
    const apiKey = '2d1119c77c14a77fee290dd58e72b536';  // OpenWeather API 키

    $(document).ready(function () {
        $('#getWeatherBtn').click(function () {
            getWeatherByCityName();
        });

        $('#cityInput').keyup(function (event) {
            if (event.key === "Enter") {
                getWeatherByCityName();
            }
        });

        setInterval(getWeatherByCityName, 600000); // 10분마다 자동 갱신
    });

    function getWeatherByCityName() {
        const city = $('#cityInput').val();

        if (!city) {
            alert("도시 이름을 입력하세요.");
            return;
        }

        // 도시 이름으로 위도와 경도 얻기
        $.ajax({
            url: 'https://api.openweathermap.org/geo/1.0/direct?q=' + city + '&limit=1&appid=' + apiKey,
            type: 'GET',
            dataType: 'json',
            success: function (data) {
                if (data.length > 0) {
                    const lat = data[0].lat;
                    const lon = data[0].lon;
                    getWeatherByCoordinates(lat, lon, city);
                    getTouristInfoByCoordinates(lat, lon);  // 위도, 경도를 사용하여 관광지 정보 가져오기
                } else {
                    alert("해당 도시를 찾을 수 없습니다.");
                }
            },
            error: function (error) {
                console.error("Error fetching coordinates:", error);
                alert("도시 정보를 가져오는 데 실패했습니다.");
            }
        });
    }

    function getWeatherByCoordinates(lat, lon, cityName) {
        $.ajax({
            url: 'https://api.openweathermap.org/data/2.5/weather?lat=' + lat + '&lon=' + lon + '&appid=' + apiKey + '&units=metric&lang=kr',
            type: 'GET',
            dataType: 'json',
            success: function (data) {
                if (data.cod === 200) {
                    displayWeather(data, cityName);
                } else {
                    alert("날씨 정보를 찾을 수 없습니다.");
                }
            },
            error: function (error) {
                console.error("Error fetching weather data:", error);
                alert("날씨 데이터를 가져오는 데 실패했습니다.");
            }
        });
    }

    function getTouristInfoByCoordinates(lat, lon) {
        const touristApiKey = 'YOUR_API_KET';  // 공공데이터 포털 API 키

        $.ajax({
            url: 'https://apis.data.go.kr/B551011/KorService1/locationBasedList1?serviceKey=' + touristApiKey + '&numOfRows=10&pageNo=1&MobileApp=AppTest&_type=json&MobileOS=ETC&mapX=' + lon + '&mapY=' + lat + '&radius=1000&contentTypeId=12',
            type: 'GET',
            dataType: 'json',
            success: function (data) {
                if (data.response.body.totalCount > 0) {
                    displayTouristInfo(data);
                } else {
                    $('#touristInfo').html('<p>해당 지역에 대한 관광 정보가 없습니다.</p>');
                }
            },
            error: function(error) {
                console.error("Error fetching tourist info:", error); // 에러내용 출력
                alert("관광 정보를 가져오는 데 실패했습니다.");
            }
        });
    }

    function displayWeather(data, cityName) {
        const currentTime = new Date().toLocaleString('ko-KR');
        $('#weatherInfo').html(
            '<h2>' + cityName + ' 날씨</h2>' +
            '<p><strong>현재 시간:</strong> ' + currentTime + '</p>' +
            '<p><strong>온도:</strong> ' + data.main.temp + '°C</p>' +
            '<p><strong>습도:</strong> ' + data.main.humidity + '%</p>' +
            '<p><strong>풍속:</strong> ' + data.wind.speed + ' m/s</p>' +
            '<p><strong>상태:</strong> ' + data.weather[0].description + '</p>'
        );
    }

    let currentPage = 1; // 현재 페이지 상태
    const itemsPerPage = 5; // 한 페이지에 표시할 관광지 개수
    let currentLat = null; // 현재 위도
    let currentLon = null; // 현재 경도

    function getTouristInfoByCoordinates(lat, lon) {
        currentLat = lat;  // 현재 위도 저장
        currentLon = lon;  // 현재 경도 저장

        const touristApiKey = 'aToHYG4xpZhS0OS59VRMVuioU5pgfn7mwvbBFbfnODC0%2Fwmwbx8DQbKtcoXyk7HXNCX9BNanoAQtqaxjpgrTJg%3D%3D';  // 관광지 API 키

        $.ajax({
            url: 'https://apis.data.go.kr/B551011/KorService1/locationBasedList1?serviceKey=' + touristApiKey + '&numOfRows=' + itemsPerPage + '&pageNo=' + currentPage + '&MobileApp=AppTest&_type=json&MobileOS=ETC&mapX=' + lon + '&mapY=' + lat + '&radius=20000&contentTypeId=12',
            type: 'GET',
            dataType: 'json',
            success: function (data) {
                if (data.response.body.totalCount > 0) {
                    displayTouristInfo(data);
                    updatePagination(data.response.body.totalCount);
                } else {
                    $('#touristInfo').html('<p>해당 지역에 대한 관광 정보가 없습니다.</p>');
                }
            },
            error: function(error) {
                console.error("Error fetching tourist info:", error); // 에러내용 출력
                alert("관광 정보를 가져오는 데 실패했습니다.");
            }
        });
    }

    function displayTouristInfo(data) {
        let touristHtml = '<h2>추천 관광지</h2>';


        const items = data.response.body.items.item;


        items.forEach(function(item) {
            const title = item.title || '명소 정보 없음';  // title 값이 없으면 기본값
            const addr = item.addr1 || '주소 미제공';  // addr1 값이 없으면 기본값

            touristHtml += '<p><strong>명소:</strong> ' + title + '</p>';
            touristHtml += '<p><strong>주소:</strong> ' + addr + '</p>';
            touristHtml += '<hr>';
        });

        // HTML을 특정 요소에 삽입
        document.getElementById("touristInfo").innerHTML = touristHtml;
    }

    function updatePagination(totalCount) {
        const totalPages = Math.ceil(totalCount / itemsPerPage); // 총 페이지 수 계산
        let paginationHtml = '';


        if (currentPage > 1) {
            paginationHtml += '<button id="prevPage" onclick="changePage(' + (currentPage - 1) + ')">이전</button>';
        }


        if (currentPage < totalPages) {
            paginationHtml += '<button id="nextPage" onclick="changePage(' + (currentPage + 1) + ')">다음</button>';
        }


        document.getElementById("touristInfo").innerHTML += paginationHtml;
    }

    function changePage(page) {
        currentPage = page;  // 페이지 변경
        getTouristInfoByCoordinates(currentLat, currentLon);  // 새로운 페이지의 데이터를 가져옵니다
    }

</script>

</body>
</html>
