class CreateF <  ActiveRecord::Migration
  def change
    create_table :films, :options => "DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci" do |t|
      t.text   :prev
      t.text   :page_video
      t.text   :name
      t.text   :image
      t.text   :genre
      t.text   :year
      t.text   :country
      t.text   :producer
      t.text   :cast
      t.text   :notice
      t.text   :date
      t.timestamps
    end


    create_table :audios, :options => "DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci" do |t|
      t.belongs_to :films
      t.text   :translit
      t.text   :name
      t.text   :quality
      t.text   :url
      t.text   :play
      t.timestamps
    end

    create_table :errors, :options => "DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci" do |t|
      t.text   :error
      t.text   :url
      t.text   :date
      t.timestamps
    end

  end


end
