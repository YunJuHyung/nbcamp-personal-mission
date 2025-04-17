//
//  TableViewCell.swift
//  WeatherAPI
//
//  Created by 윤주형 on 4/17/25.
//

import UIKit

final class TableViewCell: UITableViewCell {

    static let id = "TableViewCell"

    private let dtTxtLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .black
        return label
    }()

    private let tempLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .black
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        contentView.backgroundColor = .black

        [dtTxtLabel, tempLabel]
            .forEach{ contentView.addSubview($0) }

        dtTxtLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
        }

        tempLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
    }

    public func configureCell(forecastWeather: ForecastWeather) {
        dtTxtLabel.text = "\(forecastWeather.dtTxt)"
        tempLabel.text = "\(String(forecastWeather.main.temp))°C"
    }
}
