//
//  ViewController.swift
//  WeatherAPI
//
//  Created by 윤주형 on 4/17/25.
//

import UIKit
import SnapKit

class ViewController: UIViewController{

    private var datasource = [ForecastWeather]()

    //queryItems 생성
    private let queryItems: [URLQueryItem] = [
        URLQueryItem(name: "lat", value: "37.5"),
        URLQueryItem(name: "lon", value: "126.9"),
        URLQueryItem(name: "appid", value: WeatherAPIKey.apiKey),
        URLQueryItem(name: "units", value: "metric")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchCurrentWeatherData()
        fetchForecastData()

    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "서울특별시"
        label.font = .boldSystemFont(ofSize: 30)
        label.textColor = .white
        return label
    }()

    private let tempLabel: UILabel = {
        let label = UILabel()
        label.text = "20도"
        label.font = .boldSystemFont(ofSize: 50)
        label.textColor = .white
        return label
    }()

    private let tempMinLabel: UILabel = {
        let label = UILabel()
        label.text = "18도"
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()

    private let tempMaxLabel: UILabel = {
        let label = UILabel()
        label.text = "25도"
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()

    private let tempStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        return imageView
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .black
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.id)
        return tableView
    }()


    private func fetchData<T: Decodable>(url: URL, completion: @escaping (T?) -> Void) {
        let session = URLSession(configuration: .default)
        session.dataTask(with: URLRequest(url: url)) { data, response, error in
            guard let data, error == nil else {
                //나중에 아마 할것 같긴한데 api로 받는 실패 번수 뽑아주기
                print("데이터 로드 실패")
                completion(nil)
                return
            }

            let successRange = 200..<300
            if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
                guard let decodedData = try? JSONDecoder().decode(T.self, from: data) else {
                    print("JSON 디코딩 실패")
                    completion(nil)
                    return
                }
                completion(decodedData)
            } else {
                print("응답 오류")
                completion(nil)
            }
        }.resume()
    }

    private func fetchCurrentWeatherData() {
        var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
        urlComponents?.queryItems = self.queryItems

        print(#fileID, #function, #line, "print urlComponents?.url: \(String(describing: urlComponents?.url))")
        guard let url = urlComponents?.url else {
            print("잘못된 url")
            return
        }

        fetchData(url: url) { [weak self] (result: CurrentWeatherResult?) in
            guard let self, let result else { return }

            DispatchQueue.main.async(){
                self.tempLabel.text = "\(Int(result.main.temp))°C"
                self.tempMinLabel.text = "최소: \(Int(result.main.tempMin))°C"
                self.tempMaxLabel.text = "최고: \(Int(result.main.tempMax))°C"
            }

            guard let imageURL = URL(string: "https://openweathermap.org/img/wn/\(result.weather[0].icon)@2x.png")  else { return }


            if let data = try? Data(contentsOf: imageURL) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }

            }
        }

    }

    private func fetchForecastData() {
        var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/forecast")
        urlComponents?.queryItems = self.queryItems

        print(#fileID, #function, #line, "print urlComponents?.url: \(String(describing: urlComponents?.url))")
        guard let url = urlComponents?.url else {
            print("잘못된 url")
            return
        }


        fetchData(url: url) { [weak self] (result: ForecastWeatherResult?) in
            guard let self, let result else { return }



            for forecastWeather in result.list {
                print("\(forecastWeather.main)\n\(forecastWeather.dtTxt)\n\n")
            }

            DispatchQueue.main.async {
                self.datasource = result.list
                self.tableView.reloadData()
            }
        }

    }
    private func configureUI() {
        view.backgroundColor = .black

        [titleLabel, tempLabel, tempStackView, imageView, tableView]
            .forEach{ view.addSubview($0) }

        [tempMinLabel, tempMaxLabel]
            .forEach{ tempStackView.addArrangedSubview($0) }

        titleLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(120)
        }

        tempLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
        }

        tempStackView.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(tempLabel.snp.bottom).offset(10)
        }

        imageView.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(160)
            $0.top.equalTo(tempStackView.snp.bottom).offset(20)
        }

        tableView.snp.makeConstraints{
            $0.top.equalTo(imageView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(50)
        }

    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        40
    }
}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //줄 수
        datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //cell 재사용 및 타입 캐스팅
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.id) as? TableViewCell else
        { return UITableViewCell() }
        cell.configureCell(forecastWeather: datasource[indexPath.row])
        return cell
    }
}

