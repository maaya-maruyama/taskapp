//
//  ViewController.swift
//  taskapp
//
//  Created by 丸山万綾 on 2023/10/28.
//

import UIKit
import RealmSwift
//Realmを使うため

class ViewController: UIViewController,UITableViewDelegate,UISearchBarDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    //Realmのインスタンスを取得して読み書きのメソッドを呼び出す
    //Realmは1つのデータベースにつき1ファイルとなる
    
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    //データベース内のタスクが格納されるリスト
    //データの一覧を取得するにはRealmクラスのobjects(_:)メソッドでクラスを指定して一覧を取得する
    //(個別の読み書きではなくデータを一覧として全て取得する）
    //sorted(byKeyPath:ascending:)メソッドで並べ替えて配列を取り出す
    //日付の近い順でソート：昇順
    //以降内容をアップデートするとリスト内は自動的に更新される
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.fillerRowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return taskArray.count
    }
    //データの数（テーブルの行数）を表している
    //Realmのデータの配列であるtaskArrayの要素数を返すようにする
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        view.endEditing(true)
        if searchBar.text != nil{
            taskArray = realm.objects(Task.self).where({$0.category == searchBar.text!}).sorted(byKeyPath: "date", ascending: true)
            tableView.reloadData() //データソースを更新して，テーブルビューのリロードをかけている
        }else{
            taskArray = realm.objects(Task.self).sorted(byKeyPath: "date", ascending: true) //realm.objectが全件取得，全件取得するときはソートして並び順を指定する
            tableView.reloadData() //無条件の時に元の全件データを取得して表示する
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //再利用可能なcellを得る
        //dequeueReusableCellは再利用可能なcellのインスタンスを取得する唯一の方法（create　cell的なこと）
        //tableViewはリユースキューにセルが溜まっているのがあれば，そのインスタンスを返す
        //リユースキューにセルが溜まっていなかったらその時初めて新しいインスタンスを作成して返す
        //再利用可能なセルを取り出す，または新しいセルを作成する
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    //Realmのデータの配列であるtaskArrayから該当するデータを取り出してセルに設定する
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    //UITableViewDelegateプロトコルのメソッド（デリゲートメソッド）で，セルをタップしたときにタスク入力画面に遷移させる＞最初は中身を空のままにする
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle{
        return .delete
    }
    //UITableViewDelegateプロトコルのメソッド（デリゲートメソッド）で，セルが削除可能か，並べ替えが可能かどうかなどどのように編集ができるかを返すメソッド＞taskappでは削除可能にするため，.deleteを返す
    
    //deleteボタンが押された時に呼ばれるメソッド
    //セルを削除する時に呼び出されるもので，データベースから該当するデータを削除する必要がある
    //Realmクラスのdeleteメソッドに削除したいオブジェクト（今回はTaskクラスのインスタンス）を与えることで削除することができる
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            //削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            //ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id.stringValue)])
            //データベースから削除する
            try! realm.write{
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            //未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests{(requests: [UNNotificationRequest]) in
                for request in requests{
                    print("/----------------")
                    print(request)
                    print("/----------------")
                }
            }
        }
    }
    //UITableViewDataSourceプロトコルのメソッドでデリートボタンが押されたときにローカル通知をキャンセルし，データベースからタスクを削除する＞最初は空のままにする
    //セルを削除するときに呼び出される
    //デリートメソッドに削除したいオブジェクトを与えることで削除できる
    //さらにUITableViewクラスのdeleteRows(at:with:)
    //do{
    //  try エラーが発生する可能性のある処理
    //} catch エラータイプ{
    //  エラーが発生したときに行う処理
    //}
    //テーブル行を左にスワイプして削除ボタンを表示しタップする
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue"{
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }else{
            inputViewController.task = Task()
        }
    }
    //画面遷移の時に呼ばれるメソッドはprepare(for:sender:)
    //performSegue(withIdentifier:sender:)メソッドによってcellSegueのsegueが実行されて画面遷移する
    //今回のコードでは+ボタンをタップしたときとセルをタップした時の2つのケースで遷移することがあるので
    //条件分岐して場合分けして処理を記述
    //セルをタップしたとき＞IdentifierがcellSegueであるsegueを発行する，IdentifierがcellSegueのt機は既に作成済みのタスクを編集するときなので配列taskArrayから該当するTaskクラスのインスタンスを取り出してinputViewControllerのtaskプロパティに設定する
    //＋ボタンをタップしたときはTaskクラスのインスタンスを新しく生成して，それをそのまま渡す
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    //入力画面から戻ってきた時にTableViewを更新させる


}

