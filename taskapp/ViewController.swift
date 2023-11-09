//
//  ViewController.swift
//  taskapp
//
//  Created by 丸山万綾 on 2023/10/28.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.fillerRowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 0
    }
    //データの数（テーブルの行数）を表している
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //再利用可能なcellを得る
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    //UITableViewDelegateプロトコルのメソッド（デリゲートメソッド）で，セルをタップしたときにタスク入力画面に遷移させる＞最初は中身を空のままにする
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle{
        return .delete
    }
    //UITableViewDelegateプロトコルのメソッド（デリゲートメソッド）で，セルが削除可能か，並べ替えが可能かどうかなどどのように編集ができるかを返すメソッド＞taskappでは削除可能にするため，.deleteを返す
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }
    //UITableViewDataSourceプロトコルのメソッドでデリートボタンが押されたときにローカル通知をキャンセルし，データベースからタスクを削除する＞最初は空のままにする


}

