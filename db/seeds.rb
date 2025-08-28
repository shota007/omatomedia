# db/seeds.rb
# %w[政治 国際情勢 都市伝説 経済 アート アニメ テクノロジー ビジネス その他].each do |n|
  # Category.find_or_create_by!(name: n)
# end

ORDER = %w[政治 国際情勢 都市伝説 経済 アート アニメ テクノロジー ビジネス 未分類]

ORDER.each_with_index do |name, idx|
  Category.find_or_create_by!(name: name).tap do |cat|
    cat.update!(position: idx)
  end
end